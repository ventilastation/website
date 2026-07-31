import Foundation
import SwiftUI

/// The GPU-facing representation of the original browser wire protocol.
/// Static assets are packed once into texture-shaped arrays; each frame only
/// changes the compact scene records and the column offset.
struct NativeMetalFrameSnapshot {
    let palette: [UInt8]
    let paletteHeight: Int
    let stripAtlas: [UInt8]
    let stripAtlasHeight: Int
    let stripMeta: [UInt32]
    let scene: [UInt32]
    let drawableCount: Int
    let frameNumber: Int
    let columnOffset: Int
    let assetRevision: UInt64
    let sceneRevision: UInt64
}

final class NativeFrameStore: ObservableObject {
    struct Strip {
        let width: Int
        let height: Int
        let frames: Int
        let palette: Int
        let data: [UInt8]
    }

    @Published private(set) var frameNumber = 0
    @Published private(set) var revision: UInt64 = 0

    private var paletteData = [UInt8]()
    private var strips = [Int: Strip]()
    private var sceneData = [UInt8]()
    private var legacySprites = [UInt8]()
    private var packedScene = [UInt32]()
    private var packedDrawableCount = 0
    private var packedPalette = [UInt8](repeating: 0, count: 256 * 4)
    private var packedStripAtlas = [UInt8](repeating: 0, count: 2048)
    private var packedStripMeta = [UInt32](repeating: 0, count: 256 * 4)
    private var packedStripAtlasHeight = 1
    private var columnOffset = 0
    private(set) var assetRevision: UInt64 = 0
    private(set) var sceneRevision: UInt64 = 0

    func consumeCommand(line: Data, payload: Data) {
        let text = String(data: line, encoding: .utf8) ?? ""
        let parts = text.split(separator: " ")
        guard let command = parts.first else { return }
        switch command {
        case "palette":
            paletteData = Array(payload)
            rebuildAssetTextures()
            assetRevision &+= 1
        case "imagestrip":
            guard parts.count >= 2, let slot = Int(parts[1]), payload.count >= 4 else { return }
            let bytes = Array(payload)
            let width = bytes[0] == 255 ? 256 : max(Int(bytes[0]), 1)
            strips[slot] = Strip(
                width: width,
                height: Int(bytes[1]),
                frames: max(Int(bytes[2]), 1),
                palette: Int(bytes[3]),
                data: Array(bytes.dropFirst(4))
            )
            rebuildAssetTextures()
            assetRevision &+= 1
        case "vs2_scene":
            sceneData = Array(payload)
            packScene()
            sceneRevision &+= 1
        default:
            return
        }
        revision &+= 1
    }

    func consumeFrame(sprites: Data, metadata: Data) {
        legacySprites = Array(sprites)
        let bytes = Array(metadata)
        if bytes.count >= 16 {
            frameNumber = Int(bytes[0]) | Int(bytes[1]) << 8 | Int(bytes[2]) << 16 | Int(bytes[3]) << 24
            columnOffset = Int(bytes[6])
        }
        if sceneData.isEmpty {
            packLegacySprites()
            sceneRevision &+= 1
        }
        revision &+= 1
    }

    func snapshot() -> NativeMetalFrameSnapshot {
        return NativeMetalFrameSnapshot(
            palette: packedPalette,
            paletteHeight: max(1, packedPalette.count / (256 * 4)),
            stripAtlas: packedStripAtlas,
            stripAtlasHeight: packedStripAtlasHeight,
            stripMeta: packedStripMeta,
            scene: packedScene,
            drawableCount: packedDrawableCount,
            frameNumber: frameNumber,
            columnOffset: columnOffset,
            assetRevision: assetRevision,
            sceneRevision: sceneRevision
        )
    }

    // Kept for the legacy SwiftUI renderer in LedRingView.swift.  The active
    // path is NativeMetalRingView, which samples the packed textures directly.
    func color(at index: Int) -> Color {
        _ = index
        return .black
    }

    private func rebuildAssetTextures() {
        let paletteHeight = max(1, (paletteData.count + 1023) / 1024)
        packedPalette = paletteData
        packedPalette.resize(to: 256 * 4 * paletteHeight)

        let atlasWidth = 2048
        var meta = [UInt32](repeating: 0, count: 256 * 4)
        var bytes = [UInt8]()
        bytes.reserveCapacity(strips.values.reduce(0) { $0 + $1.data.count })
        for slot in 0..<256 {
            guard let strip = strips[slot], !strip.data.isEmpty, strip.height > 0 else { continue }
            let base = slot * 4
            meta[base] = UInt32(strip.width)
            meta[base + 1] = UInt32(strip.height)
            meta[base + 2] = UInt32(strip.frames & 0xff) | (UInt32(strip.palette) << 8)
            meta[base + 3] = UInt32(bytes.count)
            bytes.append(contentsOf: strip.data)
        }
        packedStripAtlasHeight = max(1, (bytes.count + atlasWidth - 1) / atlasWidth)
        bytes.resize(to: atlasWidth * packedStripAtlasHeight)
        packedStripAtlas = bytes
        packedStripMeta = meta
    }

    private func makeStripAtlas() -> (bytes: [UInt8], height: Int, meta: [UInt32]) {
        let atlasWidth = 2048
        var meta = [UInt32](repeating: 0, count: 256 * 4)
        var bytes = [UInt8]()
        bytes.reserveCapacity(strips.values.reduce(0) { $0 + $1.data.count })
        for slot in 0..<256 {
            guard let strip = strips[slot], !strip.data.isEmpty, strip.height > 0 else { continue }
            let base = slot * 4
            meta[base] = UInt32(strip.width)
            meta[base + 1] = UInt32(strip.height)
            meta[base + 2] = UInt32(strip.frames & 0xff) | (UInt32(strip.palette) << 8)
            meta[base + 3] = UInt32(bytes.count)
            bytes.append(contentsOf: strip.data)
        }
        let height = max(1, (bytes.count + atlasWidth - 1) / atlasWidth)
        bytes.resize(to: atlasWidth * height)
        return (bytes, height, meta)
    }

    private func packScene() {
        packedScene.removeAll(keepingCapacity: true)
        packedDrawableCount = 0
        guard sceneData.count >= 16,
              sceneData[0] == 0x56, sceneData[1] == 0x53,
              sceneData[2] == 0x32, sceneData[3] == 0 else { return }

        let version = sceneData[4]
        let layerCount = Int(sceneData[5])
        let spriteCount = Int(sceneData[6])
        let header = read16(sceneData, 8)
        let layerSize = read16(sceneData, 10)
        let spriteSize = read16(sceneData, 12)
        guard header >= 16, layerSize >= 3, spriteSize >= 18 else { return }

        var layers = [(mode: Int, visible: Bool)](repeating: (0, true), count: max(layerCount, 1))
        var offset = header
        for index in 0..<layerCount where offset + layerSize <= sceneData.count {
            layers[index] = (Int(sceneData[offset + 1]), (sceneData[offset + 2] & 1) != 0)
            offset += layerSize
        }

        // Vyruss VS2 currently emits sprite drawables.  They are packed in
        // the same four-RGBA32UI texels consumed by the canonical shader.
        for _ in 0..<spriteCount where offset + spriteSize <= sceneData.count {
            let layer = Int(sceneData[offset])
            let flags = sceneData[offset + 4]
            let visible = (flags & 1) != 0 && (layer >= layers.count || layers[layer].visible)
            if visible {
                let mode = layer < layers.count ? layers[layer].mode : Int(sceneData[offset + 3])
                let x = fixedFloor(read32(sceneData, offset + 10))
                let y = fixedFloor(read32(sceneData, offset + 14))
                var lanes = [UInt32](repeating: 0, count: 16)
                lanes[0] = UInt32(bitPattern: Int32(x))
                lanes[1] = UInt32(bitPattern: Int32(y))
                lanes[2] = UInt32(sceneData[offset + 1])
                lanes[3] = UInt32(sceneData[offset + 2])
                lanes[4] = UInt32(mode == 1 ? 1 : (mode == 0 ? 0 : 2))
                lanes[5] = UInt32((flags & 2 != 0 ? 1 : 0) | (flags & 4 != 0 ? 2 : 0))
                lanes[14] = 1 // VS2 rim-origin projection
                packedScene.append(contentsOf: lanes)
                packedDrawableCount += 1
            }
            offset += spriteSize
        }
        _ = version
    }

    private func packLegacySprites() {
        packedScene.removeAll(keepingCapacity: true)
        packedDrawableCount = 0
        guard legacySprites.count >= 5 else { return }
        let count = legacySprites.count / 5
        for slot in 0..<count {
            let offset = slot * 5
            guard legacySprites[offset + 3] != 255 else { continue }
            let rawMode = legacySprites[offset + 4]
            let mode = rawMode >= 128 ? Int(rawMode) - 256 : Int(rawMode)
            var lanes = [UInt32](repeating: 0, count: 16)
            lanes[0] = UInt32(legacySprites[offset])
            lanes[1] = UInt32(legacySprites[offset + 1])
            lanes[2] = UInt32(legacySprites[offset + 2])
            lanes[3] = UInt32(legacySprites[offset + 3])
            lanes[4] = UInt32(mode == 1 ? 1 : (mode == 0 ? 0 : 2))
            lanes[15] = 0
            packedScene.append(contentsOf: lanes)
            packedDrawableCount += 1
        }
    }

    private func read16(_ bytes: [UInt8], _ offset: Int) -> Int {
        guard offset + 1 < bytes.count else { return 0 }
        return Int(bytes[offset]) | Int(bytes[offset + 1]) << 8
    }

    private func read32(_ bytes: [UInt8], _ offset: Int) -> Int {
        guard offset + 3 < bytes.count else { return 0 }
        let value = UInt32(bytes[offset]) | UInt32(bytes[offset + 1]) << 8 | UInt32(bytes[offset + 2]) << 16 | UInt32(bytes[offset + 3]) << 24
        return Int(Int32(bitPattern: value))
    }

    // Match JavaScript/Python floor(x / 256) for negative fixed-point
    // coordinates. Swift integer division truncates toward zero, which put
    // sprites just outside the rim one pixel too far into the scene.
    private func fixedFloor(_ value: Int) -> Int {
        if value >= 0 { return value / 256 }
        return -(((-value) + 255) / 256)
    }
}

private extension Array where Element == UInt8 {
    mutating func resize(to count: Int) {
        if count > self.count { append(contentsOf: repeatElement(0, count: count - self.count)) }
        else if count < self.count { removeLast(self.count - count) }
    }
}
