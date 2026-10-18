---
layout: presentation-page
title: Ventilastation — component and protocol reference
lang: en
presentation_root: /presentations/architecture
---

[Slides](./) · [Speaker notes](handout.html) · [Source map](sources.html)

This reference describes the implementation at VSDK
[`451941f`](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa).
Transport, payload format and public API version are separate contracts.

## Computing components

| Component | Execution | Owned state and services |
| --- | --- | --- |
| Rotor ESP32-S3 | MicroPython with linked C modules, or a selected native firmware | Game state, scene graph, graphics assets, rotation phase, calibrated LED output |
| Raspberry Pi base | CPython host in no-display console mode | Controller sampling, host dispatcher, audio assets/synthesis, base relay, HTTP update/package service |
| Base Arduino | C++ serial polling loop | 16 RGB LEDs, two button lights, servo mapping and legacy timed show |
| Desktop simulation | Separate MicroPython process and CPython host | Same game runtime; host substitutes for physical display and base |
| Browser simulation | MicroPython WASM worker and JavaScript UI thread | Runtime filesystem and scenes in worker; editing, display, input and audio in UI |
| Workbench ESP32-S3 | ESP-IDF firmware | Hall stimulus, reset, passive SPI capture, USB/UART bridge and UDP preview |
| Remote gateway | Host computer service | Serial ownership, capture assembly, access policy, control lease and WebRTC video |

Sources: [platform selection](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/__init__.py),
[host entry point](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/emu.py),
[workbench](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md).

## Transports and endpoints

| Endpoints | Transport | Payload / use |
| --- | --- | --- |
| Host ⇄ rotor | 115200-baud UART, through slip ring in the assembled console | Input v2 toward rotor; host command stream toward host |
| Pi → base Arduino | 57600-baud serial | Validated `base …` and legacy `ventilagon …` lines; Pi GPIO UART fallback `/dev/ttyAMA0` |
| Rotor → LED chain | SPI clock/data; current provisioning default 30 MHz | APA102-compatible words; optional CS is consumed by workbench capture |
| Desktop host ⇄ local MicroPython | TCP port 5005; duplex named pipe on Windows | Input, host commands, assets and serialized scene state |
| Browser UI ⇄ worker | `postMessage` RPC/events | Input, runtime control, frame and host events |
| MicroPython WASM ⇄ worker JS | `__vs_host` calls into WASM memory | Pointer/length frame and command posting; primitive input fields |
| Computer ⇄ workbench | USB-Serial-JTAG ⇄ hardware UART bridge | Ordinary input/host streams; local capture/control escapes |
| Workbench ⇄ preview client | LAN UDP port 5005, discovered as `ventilastation-workbench.local` | LED chunks toward client; `hello`, `rpm`, `reset` toward board |
| Rotor ⇄ update/package server | Wi-Fi, local HTTP port 5653 | Manifest, file/partition downloads, stripped game packages |
| Remote browser ⇄ gateway | HTTPS/WSS | Identity, ticket, lease, input, signaling and audio events |
| Remote gateway ⇄ browser | WebRTC H.264 / DTLS-SRTP | Display media via direct ICE or TURN relay |
| VPS ⇄ local gateway | Authenticated FRP tunnel → `127.0.0.1:8765` | Exposes the local HTTP/WebSocket service |

TCP 5005 and workbench UDP 5005 are different services and different protocols.
The browser simulator does not open either socket to execute its local game.
The physical console's UART does not carry a full graphics stream.

Sources: [connection implementations](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py),
[board provisioning defaults](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/Makefile),
[browser platform](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/browser.py),
[remote topology](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/remote-workbench-access.md).

## Board wiring configuration

These are provisioning presets, not a claim that every deployed board has the
same processor or wiring. NVS namespace `vs_board` supplies the actual values
to both MicroPython and native firmware.

| Preset | Hall GPIO | SPI clock / data / CS | Rotor UART TX / RX |
| --- | --- | --- | --- |
| Ventilastation III default | 7 | 12 / 13 / 14 | 5 / 6 |
| `configure-board-v2` | 6 | 15 / 16 / 14 | 10 / 9 |
| `configure-board-eu` | 4 | 15 / 16 / 14 | 10 / 9 |

The current default also selects SPI host 2 at 30 MHz and UART 2 at 115200.
The base Arduino firmware uses pin 7 for its 16-LED NeoPixel strip
(`NEO_KHZ800` configuration), pins 2/3 for button lights, and pin 10 for
the Servo library. Its 0–255 servo command maps to Arduino-local endpoints.

Sources: [Makefile presets](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/Makefile),
[base firmware constants](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/base/vsbase_arduino/vsbase_arduino.ino).

## Host → rotor: input protocol v2

A joystick snapshot is four bytes:

```text
2A | joy1 | joy2 | extra
```

`joy1` and `joy2` use bits 0–6 for Left, Right, Up, Down, A, B and C/X.
`extra` uses bits 0/1 for P1/P2 Y, bits 2/3 for P1 Start/Back, bits 4/5 for
P2 Start/Back, and bit 6 as reserved. Every data byte has bit 7 clear.
`2A 12 00 00` means Player 1 holds Right and A.

The parser consumes exactly three bytes after `2A`. It replaces the latest
state when that frame is complete. A payload byte equal to `2A` or an ASCII
letter remains a data byte at those positions.

Discrete commands begin with an ASCII alphanumeric and end in newline:

```text
exit\n
ota_start http://ventilastation-base.local:5653\n
```

Commands queue separately; Director dispatches one per tick. Command
accumulation has a 256-byte cap. Input transmission cadence depends on the
host engine; the Pi console engine sends changed state rather than requiring
a constant 30 Hz packet stream.

RESYNC is recognized independently of parser state:

```text
0A 0A D2 45 53 59 4E 43 0A
\n \n  D2 E  S  Y  N  C \n
```

A device restarts or reinitializes and responds with
`VENTILASTATION <WORKBENCH|BASE|ROTOR> <version> <githash>\n`.
The workbench intercepts its own RESYNC. The local USB-ID registry normally
selects boards without repeatedly resetting them.

Sources: [actual parser](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/input_parser.py),
[input specification](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/input-protocol-v2.md),
[change-based console sending](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/consoleengine.py).

## Runtime → host: command stream

```text
<command> [arguments]\n[optional binary payload]
```

The selected handler determines the binary length. A payload may contain
newline bytes. There is no universal JSON envelope, sequence number or CRC
for this stream.

| Family | Examples and framing |
| --- | --- |
| Clip audio | `sound <track>`, `music <track> [loop]`, `notes <folder> <list>` |
| Base output | `base leds <r> <g> <b>`, `base servo <0..255>`, `base buttons <mask> <blink_ms>` |
| Native audio | `achip <system>`, `aframe <nbytes> <nsamples>` + binary log, `amap <nbytes>` + auxiliary state, `astop` |
| Diagnostics | `traceback <nbytes>` / `info <nbytes>` + UTF-8 bytes; `debug` + a fixed 512-byte timing log |
| Calibration | Input `povcal get/set/commit/revert/factory`; output `povcal_state <schema> <generation> <nbytes>` + profile |
| Maintenance | `ota_progress`, `ota_done`, `ota_error`; corresponding `install_*` status lines |
| Simulation display | `imagestrip <slot> <nbytes>` + strip; `palette <count>` + count × 1024 bytes; `vs2_scene <nbytes>` + scene; legacy `sprites` + 500 bytes |
| Original Ventilagon host adapter | `ventilagon enter <seed>`, `ventilagon tick <us> <buttons>`, `ventilagon exit`; host executes shared C locally |

`frame_rgb` denotes 256 × 54 × 3 raw RGB bytes. Native Ventilagon presents
those pixels locally in the desktop host or directly from native WASM memory
in the worker; the pixels bypass the MicroPython process connection.
`frame_apa102` denotes four bytes per cell from the workbench, whose actual
transport is the separate UDP chunk protocol below.

Sources: [host protocol](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/host-protocol.md),
[actual dispatcher](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py),
[shared original game core](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/ventilagon/README.md).

## Scene API and scene wire format

The public API is **VS2 revision 2**. Its current exported scene payload is
**wire version 3**. The older host-protocol document's first-version table
is not the full current layout.

| Header offset | Field |
| --- | --- |
| 0–3 | Magic `56 53 32 00` (`VS2` + NUL) |
| 4 | Version `3` |
| 5, 6, 7 | Layer, sprite and tilemap counts |
| 8–9, 10–11 | Header size `16`, layer record size `8`, little-endian u16 |
| 12–13, 14–15 | Sprite record size `24`, tilemap record size `32`, little-endian u16 |

Records follow the header, then tile cells and two-byte draw references
(kind and record index) in paint order. Positions are fixed-point. Image
strips and palette data are separate resources. Current target budgets are
8 layers, 100 sprites and 16 tilemaps.

On hardware, the native backend receives scene/drawable state directly.
Serialized scene bytes are for simulation hosts; they are not sent over the
rotor/base UART every game tick.

Sources: [encoder and constants](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/vs2/__init__.py),
[decoder](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/povrender.py).

## LED output and captured frames

A LED word is `[0xE0 | global_brightness, B, G, R]`. Current NS107S strips
use the APA102-compatible format. The driver sends a 444-byte transfer
buffer, including start/end clocks and the two arm views with their
intentionally shared centre. This is not 108 distinct LEDs: the strip has
107 physical LEDs, forming a logical 256 × 54 polar image.

Current provisioning defaults SPI to 30 MHz; older workbench text cites
20 MHz. Actual wiring and frequency come from board NVS. CS delimits SPI
capture transactions for the workbench; the LED chain itself ignores CS.

At 600 RPM, one revolution lasts 100 ms and an angular bin lasts
390.625 µs. Ideal 444-byte wire time at 30 MHz is 118.4 µs, excluding
software costs. Two 55,296-byte internal-SRAM framebuffers separate image
projection from immediate column service.

Sources: [driver](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c),
[provisioning](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/Makefile),
[colour pipeline](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/pov-color-pipeline.md).

## Workbench UDP preview

| Bytes | Meaning |
| --- | --- |
| 0 | Magic `A1` |
| 1–4 | Snapshot sequence, u32 little-endian |
| 5 | Chunk index `0..63` |
| 6–869 | 864 raw LED bytes: 4 columns × 54 cells × 4 bytes |

A complete logical capture is 55,296 bytes across 64 datagrams of 870 bytes
each. Sequence increments per snapshot, not per revolution. Clients track
freshness per chunk. A lost packet leaves old pixels for those columns;
there is no retransmission.

Client control uses ASCII datagrams `hello\n`, `rpm <n>\n`, `reset\n`.
The most recent sender becomes the preview subscriber; `hello` is sent once
per second and the subscription expires after five seconds of silence.
This is a local, unauthenticated UDP service.

Source: [workbench protocol and semantics](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md),
[firmware sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/workbench/workbench_esp32s3/main/telemetry.c),
[host reassembly](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/workbench_telemetry.py).

## Workbench USB capture

```text
Host → workbench: D3 + "capture\n"
Workbench → host: "wb_frame 55296 <crc32>\n" + 55,296 bytes
```

`D3` introduces a workbench-local command rather than ordinary rotor input.
A locked snapshot and CRC make the capture suitable for repeatable byte
comparison. Logging and UART forwarding pause during its binary response.
`D3 + "rpm <n>\n"` also controls the Hall simulator and receives `wb_ok …`.

Source: [acceptance protocol and gates](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-hardware-acceptance.md).

## Asset ROMs, native apps and maintenance

Sprite ROMs contain strip/palette counts, offset tables, strips and palettes.
A strip has a UTF-8 name, `width-1`, height, `frames-1`, palette index,
column-major indexed pixels, and a glyph-table trailer. Index `FF` is
transparent. On flash, `.romz` adds a u32 uncompressed size and gzip data.
Sound files remain on the host. This format is separate from console ROMs.
[Normative sprite container](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/rom-format.md).

Native Retro-Go launch writes app/system/ROM selection to NVS, selects a
boot partition and reboots. Native exit targets normal `micropython`;
`factory` is permanent recovery. Original Ventilagon instead uses linked C
inside MicroPython. [On-device design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/on-device-design.md).

OTA starts with `ota_start <URL>\n` on the control stream. A persisted
request and reboot start the updater before the normal renderer. The rotor
pulls `GET /manifest`, `/files/…` and `/partitions/…` over local HTTP port
5653, using hashes for content verification and incremental updates.
File sync, native partitions and normal MicroPython are separate tiers;
firmware self-replacement hands off through recovery. [Current OTA design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/ota.md).

Game installation uses `POST /packages/<slug>.vs2`, followed by
`POST /packages/<slug>/install`. The base sends
`install_start <url> <sha256> <size>\n`; the rotor reboots and pulls the
stripped `.no-sound.vs2` ZIP. Status is polled through
`GET /packages/<slug>/status`. The package document leaves its real-board
acceptance checklist pending. [Package contract](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/game-packages.md).
