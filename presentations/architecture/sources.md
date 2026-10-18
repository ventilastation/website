---
layout: presentation-page
title: Ventilastation architecture — research and sources
lang: en
presentation_root: /presentations/architecture
---

[Open the slides](./) · [Slides with source notes](handout.html) · [Presenter guide](presenter-guide.html)

Research cutoff: **October 18, 2026**. Current architecture uses the local
VSDK `main` snapshot
[`451941fa66341ec22f09aa39fb5147b58b3e83fa`](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa),
whose latest commit is October 13. “Current” means the implementation at that
revision; it does not establish what is installed in every physical machine.
Individual slides link their evidence in speaker notes.

## The three code repositories

| Repository and snapshot | What was inspected |
| --- | --- |
| [clubdejaqueo/super-ventilagon](https://github.com/clubdejaqueo/super-ventilagon/tree/f4040113e562af43333f63e0271c6e80e2c610c0) | Full Git history and 2015 Arduino rotor, game-state, LED, serial/audio and controller code |
| [alecu/ventilastation](https://github.com/alecu/ventilastation/tree/c39710f) | Historical commits and files before the repository was emptied; LoBo MicroPython fork, C renderer, Python scenes, desktop emulator and base |
| [ventilastation/vsdk](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa) | Full local history, current runtime, hardware drivers, partition table, emulators, asset formats, tests and internal documentation |

The old `alecu/ventilastation` repository's current root only redirects to
VSDK. Its pre-cleanup history is necessary to understand the architecture.
Its January 2018 root history belongs to upstream LoBo MicroPython; the first
identified Ventilastation-specific commit is in November 2018.

## Chronology supported by primary evidence

| Date | Evidence | What it establishes |
| --- | --- | --- |
| 2012 | [Earlier history presentation](../../dump2024/) | Super Hexagon's place in the origin story; does not establish a working fan in 2012 |
| 2013 | Same talk, PyCamp Villa Giardino and prototype frames | Seven-LED experiment and the community setting |
| May 19, 2015 | [First game commit](https://github.com/clubdejaqueo/super-ventilagon/commit/0bc57b2) | Beginning of the published Arduino-game history |
| November 18, 2018 | [First ESP32 prototype](https://github.com/alecu/ventilastation/commit/9435a21ca5d2fa00211896c9ca45e2f50d53172d) | POV C code added within the MicroPython firmware fork |
| February–March 2019 | [Emulator import](https://github.com/alecu/ventilastation/commit/67c0cf6), [TCP sprite updates](https://github.com/alecu/ventilastation/commit/b1b9578), [single-socket connection](https://github.com/alecu/ventilastation/commit/d53a5ad) | Desktop development path and its communication boundary |
| August–September 2023 | [Arduino-to-C migration](https://github.com/alecu/ventilastation/commit/4ed9bc8), [queue bridge](https://github.com/alecu/ventilastation/commit/f893781) | Original Super Ventilagon incorporated into the ESP32 runtime |
| August 21, 2024 | [Import into VSDK](https://github.com/ventilastation/vsdk/commit/6b799b9) | New SDK repository; not a completely new game engine |
| October 2024 | [Vanilla MicroPython C modules](https://github.com/ventilastation/vsdk/commit/7206324), [ESP32-S3 working](https://github.com/ventilastation/vsdk/commit/e1485bc) | Firmware/toolchain separation and S3 support |
| April 2025 | [Mechanical assembly documentation](https://github.com/ventilastation/vsdk/commit/8842bc9) | Slip-ring assembly documented by this date; does not date first adoption |
| May and October 2025 | [May jam games](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa/games/vsjam-may25), [October jam games](https://github.com/ventilastation/vsdk/tree/451941fa66341ec22f09aa39fb5147b58b3e83fa/games/vsjam-oct25) | Multiple independent game contributions |
| June 12, 2025 | [Old repository redirect](https://github.com/alecu/ventilastation/commit/31aa4881dc94519ff3c08e8ed84b40c31628fc6a) | End of the old repository's active presentation as the project home |
| March–June 2026 | [WASM worker scheduler](https://github.com/ventilastation/vsdk/commit/8b044ce), [Monaco IDE](https://github.com/ventilastation/vsdk/commit/0a5340d) | Current browser runtime and editing milestones; earlier JavaScript display experiments existed |
| June–July 2026 | [Voom boot chain](https://github.com/ventilastation/vsdk/commit/fa2baaa), [NES/SMS integration](https://github.com/ventilastation/vsdk/commit/3173b16), [workbench](https://github.com/ventilastation/vsdk/commit/bb9eab0), [OTA](https://github.com/ventilastation/vsdk/commit/92d8e80) | Native firmware partitions and an expanded hardware development loop |
| July 2026 | [Single-task framebuffer correction](https://github.com/ventilastation/vsdk/commit/8946100), [sealed VS2 implementation](https://github.com/ventilastation/vsdk/commit/a258076), [API merge](https://github.com/ventilastation/vsdk/commit/d230a1f) | Current renderer scheduling and API revision 2 |
| October 13, 2026 | [Shared original C game core](https://github.com/ventilastation/vsdk/commit/2521a87) | Desktop/native-library and browser/WASM Ventilagon adapters reuse rotor C sources |

Dates above are commit dates unless the evidence is explicitly the earlier
talk. A commit establishes that code or documentation existed; it is not
automatically the date of first construction, public exhibition or deployment.

## Earlier talks and web research

The local [Making games presentation](../making-games/) supplied the current
visual context, gallery captures and examples. Its current content describes
the October 14, 2026 Circular Arcades meetup. Its presentation-index summary
has older event/duration wording, so the slides and their notes took precedence.

The local [dump2024 presentation](../../dump2024/) supplied the origin story,
component lists and historical photos. Its README says 2024, but the checked-in
Sozi source has a 2025 title and later additions. It is treated as a living
source, with individual statements checked against code history.

The published [PyDay Hurlingham history talk](https://eventos.python.org.ar/media/talks/juegos-en-un-ventilador-con-micropython-alecu-PyDayHurlingham-2024.html)
independently preserves the 2012 Super Hexagon / 2013 PyCamp / 2015 Super
Ventilagon / 2019 Ventilastation sequence. It is the presenter's own earlier
talk, rather than an independent technical audit.

[Make's February 2016 coverage](https://makezine.com/article/home/fun-games/arduino-leds-transform-your-fan-video-game-display/)
and other contemporary coverage were used as historical cross-checks. They
were not used to determine current hardware specifications or firmware
behavior; those claims use primary source code and project documentation.

## Current technical sources

All links in this list point to the inspected VSDK revision.

- [POV implementation](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c): column scheduling, Hall filtering, double buffers, centre LED and original game path.
- [Current VS2 decisions](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-decisions.md): implemented ownership, sealing and lifecycle rules.
- [On-device architecture](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/on-device-design.md) and [partition table](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/partitions-ventilastation.csv): normal boot, native apps, storage and shared NVS.
- [ROM format](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/rom-format.md), [input protocol](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/input-protocol-v2.md) and [host protocol](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/host-protocol.md): platform contracts.
- [Browser architecture](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/web-emulator-architecture.md): worker, MicroPython/WASM and pointer-based bridge.
- [Colour pipeline](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/pov-color-pipeline.md): NS107S hardware statement, shared encoder and persistent calibration.
- [Audio bridge](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/emulator-audio.md): chip-register transport, host synthesis and stated validation limits.
- [OTA](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/ota.md): three update tiers and permanent recovery.
- [Workbench](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md), [acceptance checks](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-hardware-acceptance.md) and [remote access](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/remote-workbench-access.md): real-board stimulus, observation and test scope.
- [Native Ventilagon adapter](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/ventilagon/README.md): shared original C, simulation clock and parity tests.

## Conflicts resolved during research

1. **Year of origin:** the user's 2012 starting point is retained as the
   beginning of the story. Working prototype and finished-game dates remain
   2013 and 2015 pending the author's clarification.
2. **Inherited history:** LoBo commits predate Ventilastation-specific work;
   they are not evidence that Ventilastation launched in early 2018.
3. **Renderer task placement:** a source comment describes projection in a
   core-1 task. Actual `coreTask()` projects on core 0, and the July 23
   single-task correction explains the change. The talk follows actual code.
4. **Native boot design:** earlier handoff plans describe factory as normal
   MicroPython and mention future same-image takeover. The actual table and
   current OTA documentation establish separate normal/recovery partitions
   and reboot-based native handoff.
5. **Audio status:** the audio document's status section and later browser
   section update the original plan. Device/host implementations exist;
   the same document still requests real-hardware audio verification.
6. **Validation versus implementation:** test definitions and old successful
   acceptance commits do not prove this exact checkout passed on a board
   during preparation. No new physical test was performed.

## Asset provenance

No images were generated. All images are existing project assets reused by
relative URL, preserving their original files.

| Slides | Asset | Provenance |
| --- | --- | --- |
| 1 | `making-games/assets/cover.jpg` | Existing website `images/banner.jpg`, reused as the earlier talk's cover |
| 2 | `making-games/assets/vs-gameon.jpg` | Supplied by Alejandro J. Cura for the earlier talk |
| 3 | `making-games/assets/display-arxels.png` | Existing SDK WebGL capture; backend and hash in that talk's `assets/captures.json` |
| 5 | `dump2024/images/vsdump_45.jpg`, `vsdump_49.jpg` | PyCamp prototype photos from the history talk; individual photographer credit awaits confirmation |
| 6, 8, 9 | `dump2024/images/vsdump_48.jpg`, `vsdump_50.jpg`, `vsdump_65.jpg` | Early fan and Ventilastation photos from the history talk; individual credit awaits confirmation |
| 10 | `dump2024/images/vsdump_ 13.png` | Desktop emulator screenshot; source Sozi frame “Emulador” references `image1-325`; capture date is not established |
| 11, 13 | `making-games/assets/catalog-*.png` | Existing WebGL captures of real games; exact slugs, backend and hashes in `assets/catalog-captures.json` |
| 16 | `making-games/assets/dream-garden.png` | Existing WebGL Dream Garden capture; source hash and capture metadata in `assets/captures.json` |

The history talk's acknowledgements say many photographs are CC-BY-NC images
from Facundo Batista's Flickr. They do not identify which images. The draft
preserves that provenance and asks for individual attribution; it does not
invent a photographer, license version or original photo URL.
