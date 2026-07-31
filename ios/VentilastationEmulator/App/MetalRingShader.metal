#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
};

struct RingUniforms {
    uint drawableCount;
    uint columnOffset;
    uint starCount;
    uint reserved;
    float2 viewport;
    float2 padding;
};

vertex VertexOut ringVertex(uint vertexID [[vertex_id]]) {
    const float2 positions[3] = { float2(-1.0, -1.0), float2(3.0, -1.0), float2(-1.0, 3.0) };
    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    return out;
}

constant int COLUMNS = 256;
constant int PIXELS = 54;
constant int ROWS = 256;
constant int ATLAS_WIDTH = 2048;
constant int TRANSPARENT_INDEX = 255;
constant int MODE_PLANET = 0;
constant int MODE_TUNNEL = 1;

uint stripByte(texture2d<uint, access::read> strips, int offset) {
    return strips.read(uint2(uint(offset % ATLAS_WIDTH), uint(offset / ATLAS_WIDTH))).x;
}

uint4 sceneTexel(texture2d<uint, access::read> scene, int row, int texel) {
    return scene.read(uint2(uint(texel), uint(row)));
}

int deepspaceAt(texture2d<uint, access::read> deepspace, int y, bool vs2) {
    return int(deepspace.read(uint2(uint(clamp(y, 0, ROWS - 1)), uint(vs2 ? 2 : 0))).x);
}

int2 deepspaceRange(texture2d<uint, access::read> deepspace, int led, bool vs2) {
    uint packed = deepspace.read(uint2(uint(clamp(led, 0, PIXELS - 1)), uint(vs2 ? 3 : 1))).x;
    return int2(int(packed & 255u), int((packed >> 8) & 255u));
}

float4 paletteColor(texture2d<float, access::read> palette, int paletteIndex, int colorIndex) {
    float4 texel = palette.read(uint2(uint(clamp(colorIndex, 0, 255)), uint(max(paletteIndex, 0))));
    // Wire entry is [0xFF, B, G, R].
    return float4(texel.w, texel.z, texel.y, 1.0);
}

int positiveMod(int value, int modulo) {
    int wrapped = value % modulo;
    return wrapped < 0 ? wrapped + modulo : wrapped;
}

int sourceColumnFor(int x, int width, int renderColumn, bool flipX) {
    int spriteColumn = width - 1 - positiveMod(renderColumn - x, COLUMNS);
    if (spriteColumn < 0 || spriteColumn >= width) return -1;
    return flipX ? width - 1 - spriteColumn : spriteColumn;
}

bool probeSprite(texture2d<uint, access::read> strips,
                 texture2d<uint, access::read> stripMeta,
                 texture2d<float, access::read> palette,
                 texture2d<uint, access::read> scene,
                 texture2d<uint, access::read> deepspace,
                 int row, int renderColumn, int led, thread float4 &color) {
    uint4 meta = stripMeta.read(uint2(sceneTexel(scene, row, 0).z, 0));
    int width = int(meta.x);
    int height = int(meta.y);
    if (width == 0 || height == 0) return false;

    int totalFrames = max(int(meta.z & 255u), 1);
    int paletteIndex = int(meta.z >> 8);
    int stripOffset = int(meta.w);
    uint4 texel0 = sceneTexel(scene, row, 0);
    uint4 texel1 = sceneTexel(scene, row, 1);
    uint4 texel3 = sceneTexel(scene, row, 3);
    int x = as_type<int>(texel0.x);
    int y = as_type<int>(texel0.y);
    int frame = int(texel0.w) % totalFrames;
    int mode = int(texel1.x);
    int flags = int(texel1.y);
    bool flipY = (flags & 2) != 0;
    bool vs2 = texel3.z != 0u;
    int sourceColumn = sourceColumnFor(x, width, renderColumn, (flags & 1) != 0);
    if (sourceColumn < 0) return false;
    int base = stripOffset + sourceColumn * height + frame * width * height;

    if (mode == MODE_PLANET) {
        int zleds = vs2 ? deepspaceAt(deepspace, y, true) + 1 : deepspaceAt(deepspace, 255 - y, false);
        if (led >= zleds) return false;
        int sourceRow = (led * PIXELS) / max(zleds, 1);
        if (sourceRow >= height) return false;
        if (!flipY) sourceRow = height - 1 - sourceRow;
        int index = int(stripByte(strips, base + sourceRow));
        if (index == TRANSPARENT_INDEX) return false;
        color = paletteColor(palette, paletteIndex, index);
        return true;
    }

    if (mode != MODE_TUNNEL) {
        int destY = PIXELS - 1 - led;
        if (destY < y || destY >= y + height || destY >= ROWS) return false;
        int sourceRow = destY - y;
        if (flipY) sourceRow = height - 1 - sourceRow;
        int index = int(stripByte(strips, base + sourceRow));
        if (index == TRANSPARENT_INDEX) return false;
        color = paletteColor(palette, paletteIndex, index);
        return true;
    }

    int2 range = deepspaceRange(deepspace, led, vs2);
    int scanLo = max(range.x, max(y, 0));
    int scanHi = min(range.y, min(y + height - 1, ROWS - 1));
    for (int destY = scanHi; destY >= scanLo; --destY) {
        int sourceRow = destY - y;
        if (flipY) sourceRow = height - 1 - sourceRow;
        int index = int(stripByte(strips, base + sourceRow));
        if (index != TRANSPARENT_INDEX) {
            color = paletteColor(palette, paletteIndex, index);
            return true;
        }
    }
    return false;
}

fragment float4 ringFragment(
    VertexOut in [[stage_in]],
    constant RingUniforms &u [[buffer(0)]],
    texture2d<uint, access::read> strips [[texture(0)]],
    texture2d<uint, access::read> stripMeta [[texture(1)]],
    texture2d<float, access::read> palette [[texture(2)]],
    texture2d<uint, access::read> scene [[texture(3)]],
    texture2d<uint, access::read> deepspace [[texture(4)]]) {
    float2 center = u.viewport * 0.5;
    float radius = min(u.viewport.x, u.viewport.y) * 0.5;
    float2 delta = in.position.xy - center;
    float normalizedRadius = length(delta) / max(radius, 1.0);
    // The physical LED columns run from the hub all the way to the rim.  The
    // earlier SwiftUI placeholder used a 20% inner gap, but that is not part
    // of the Ventilastation display and made the Metal output look hollow.
    if (normalizedRadius > 1.0) return float4(0.0);

    constexpr float pi = 3.14159265359;
    constexpr float twoPi = 6.28318530718;
    float angle = atan2(delta.y, delta.x) + pi * 0.5;
    if (angle < 0.0) angle += twoPi;
    int column = clamp(int(floor(angle / twoPi * float(COLUMNS))), 0, COLUMNS - 1);
    float ringStart = 0.0;
    float ringSpan = 1.0;
    int led = int(floor((normalizedRadius - ringStart) / ringSpan * float(PIXELS)));
    if (led < 0 || led >= PIXELS) return float4(0.0);
    int renderColumn = (column + int(u.columnOffset)) & (COLUMNS - 1);

    float4 color = float4(0.0);
    bool hit = false;
    for (int row = 0; row < int(u.drawableCount); ++row) {
        if (probeSprite(strips, stripMeta, palette, scene, deepspace, row, renderColumn, led, color)) {
            hit = true;
            break;
        }
    }
    if (!hit) return float4(0.0);

    float ledCenter = ringStart + (float(led) + 0.5) / float(PIXELS) * ringSpan;
    float radial = 1.0 - smoothstep(0.018, 0.040, abs(normalizedRadius - ledCenter));
    return float4(color.rgb * max(radial, 0.35), 1.0);
}
