---
layout: presentation-page
title: Ventilastation architecture — implementation source map
lang: en
presentation_root: /presentations/architecture
---

[Slides](./) · [Speaker notes](handout.html) · [Protocol reference](protocol-reference.html)

Current implementation: VSDK
[`451941fa66341ec22f09aa39fb5147b58b3e83fa`](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa),
latest commit October 13, 2026; inspection cutoff October 18. Speaker notes
link individual claims to these sources. An implemented path and a successful
host test do not establish deployment in every physical machine.

## Hardware and execution owners

| Subject | Primary source |
| --- | --- |
| Fan, slip ring and external power | [Mechanical assembly](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/3dmodels/Mechanical%20Assembly.md) |
| Wiring, UART and SPI defaults | [Provisioning Makefile](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/Makefile), [board NVS interface](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/board_config.py) |
| Hall timing, core loop, DMA and framebuffers | [POV driver](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c), [core definition](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/minispi.h) |
| NS107S output and calibration | [Colour pipeline](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/pov-color-pipeline.md) |
| Pi no-display host | [ConsoleEngine](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/consoleengine.py), [host entry point](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/emu.py) |
| Arduino actuators and local timing | [Base firmware](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/base/vsbase_arduino/vsbase_arduino.ino), [base control contract](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/base-control-api.md) |

## Runtime and protocols

| Subject | Primary source |
| --- | --- |
| Boot, recovery and update intent | [main.py](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/main.py) |
| App discovery, loading and callbacks | [Catalog](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/catalog.py), [loader](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/app_loader.py), [Director](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py) |
| Platform implementations | [Selection](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/__init__.py), [hardware](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/hardware.py), [desktop](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/desktop.py), [browser](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/browser.py) |
| Input v2 and RESYNC | [Specification](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/input-protocol-v2.md), [actual parser](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/input_parser.py) |
| Host command framing and transports | [Protocol](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/host-protocol.md), [connection classes and dispatcher](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py) |
| VS2 scene ownership and wire payload | [Implementation / encoder](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/vs2/__init__.py), [decoder](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/povrender.py), [accepted API decisions](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-decisions.md) |
| Sprite ROM container | [Normative format](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/rom-format.md), [rotor image builder](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/build_micropython_fs.py) |
| Audio and host synthesis | [Audio bridge status / design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/emulator-audio.md), [desktop synthesis](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/emu_audio.py) |
| Firmware partitions and native handoff | [Actual table](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/partitions-ventilastation.csv), [on-device design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/on-device-design.md), [native C hook](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/native_apps/native_apps.c) |
| Original Ventilagon shared C adapters | [Desktop / WASM integration](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/ventilagon/README.md) |

## Development, observation and maintenance

| Subject | Primary source |
| --- | --- |
| Worker RPC and memory bridge | [WASM worker](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/web/wasm-worker.js), [bridge](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/web/micropython-bridge.js), [architecture](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/web-emulator-architecture.md) |
| Workbench signals and UDP | [Design / wire format](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md), [telemetry sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/workbench/workbench_esp32s3/main/telemetry.c), [host reassembly](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/workbench_telemetry.py) |
| USB capture, CRC and acceptance gates | [Hardware acceptance](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-hardware-acceptance.md) |
| Remote control / video | [Remote design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/remote-workbench-access.md), [gateway](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/remote_gateway.py) |
| HTTP updates and recovery | [Current OTA design](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/ota.md), [HTTP server](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/upgrade_server.py) |
| Game packages | [Format / flow / validation status](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/game-packages.md), [base manager](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/package_manager.py), [board installer](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/installer.py) |

## Documentation differences resolved against code

1. The host-protocol document describes the first scene payload. The current
   encoder uses wire version 3, while the public API is revision 2.
2. Workbench prose cites 20 MHz SPI; the current provisioning default is
   30 MHz. It is a per-board NVS value.
3. A renderer comment describes projection on core 1. Actual `coreTask()`
   projects and serves on core 0, following the [single-task correction](https://github.com/ventilastation/vsdk/commit/8946100).
4. The input document describes loop-rate transmission. The Pi ConsoleEngine
   sends changed state; packet cadence is not a universal protocol guarantee.
5. A variable named `UDP_THIS` in runtime comms is used to create a TCP
   `SOCK_STREAM` server. Workbench UDP is a distinct implementation.
6. Older native handoff prose treats factory as normal MicroPython. The
   current table and OTA implementation separate normal `micropython` from
   permanent `factory` recovery.
7. Audio and game-package documents describe implemented paths while retaining
   real-board validation work. The talk preserves that distinction.

## Short architectural history

The evolution slide uses the
[2015 Arduino repository](https://github.com/clubdejaqueo/super-ventilagon/tree/f4040113e562af43333f63e0271c6e80e2c610c0),
the historical [alecu/ventilastation tree](https://github.com/alecu/ventilastation/tree/c39710f),
and the [local history talk](../../dump2024/). The first identified
Ventilastation-specific ESP32 commit is [November 18, 2018](https://github.com/alecu/ventilastation/commit/9435a21ca5d2fa00211896c9ca45e2f50d53172d);
the older January 2018 root history is inherited LoBo MicroPython work.

VSDK [imports apps/emulator in August 2024](https://github.com/ventilastation/vsdk/commit/6b799b9),
[uses upstream MicroPython C modules in October](https://github.com/ventilastation/vsdk/commit/7206324)
and [records S3 working](https://github.com/ventilastation/vsdk/commit/e1485bc).
Slip-ring assembly is [documented by April 2025](https://github.com/ventilastation/vsdk/commit/8842bc9),
which does not establish its first construction date. The 2012 inspiration /
2013 experiment / 2015 game sequence comes from the earlier talk; unresolved
origin and installed-revision questions remain in the presenter guide.

## Visual provenance and calculated values

All component diagrams and packet displays are editable HTML/CSS descriptions
of the cited implementation. No historical photo gallery or generated imagery
is used. The only photograph is the cover background,
[`making-games/assets/cover.jpg`](../making-games/assets/cover.jpg), inherited
from website `images/banner.jpg` through the earlier presentation.

The timing, buffer and bandwidth numbers are calculations, not new board
measurements: 600 RPM → 100 ms/revolution → 390.625 µs/column; 444 bytes at
30 MHz → 118.4 µs ideal wire time; two 256 × 54 × 4-byte buffers → 110,592
bytes; 115200 8N1 → 11,520 bytes/s; 32 kHz 16-bit stereo PCM → 128,000 bytes/s.
