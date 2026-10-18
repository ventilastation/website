---
layout: presentation-page
title: Presenting Ventilastation system architecture
lang: en
presentation_root: /presentations/architecture
---

[Slides](./) · [Speaker notes](handout.html) · [Protocol reference](protocol-reference.html) · [Sources](sources.html)

This technical talk has **26 slides and 30 minutes of speaking time**.
It maps components and execution boundaries first, then follows the transports
and custom formats joining them. Architectural evolution occupies one
90-second comparison near the end. The intended audience understands basic
software processes and serial/network links; define the project's own terms.

## Pacing

| Time | Slides | Content |
| --- | --- | --- |
| 0:00–1:10 | 1–2 | Deployment modes and the meaning of “host” |
| 1:10–5:30 | 3–6 | Three computing boards, mechanical timing, SPI, power and calibration |
| 5:30–9:00 | 7–9 | Software owners, platform backends, rendering and concurrency |
| 9:00–15:25 | 10–14 | Input v2, host framing, input-to-output trace, Arduino and audio |
| 15:25–21:10 | 15–19 | Graphics storage, firmware ownership, desktop and browser transports, scene serialization |
| 21:10–25:20 | 20–22 | Electrical workbench, UDP/USB capture and remote access |
| 25:20–27:55 | 23–24 | OTA and game-package control/data flows |
| 27:55–30:00 | 25–26 | Architectural evolution and interface synthesis |

The `data-timing` values total 1,800 seconds and match the elapsed cues in
speaker notes. Questions follow the timed talk. No live demonstration is
needed. If questions must fit inside the slot, rehearse a shorter version and
change both the cues and Reveal's `totalTime`; do not silently run the
30-minute version into Q&A.

## How to explain the diagrams

Start every diagram with its deployment mode. Name the process or board that
owns state, then the transport and the payload. In particular:

- The Pi's **host** software also runs on the desktop; it is not the Python
  game interpreter on the physical console.
- The rotor/base link is **115200 UART**; the separate Pi/Arduino link is
  **57600 serial**.
- A physical rotor drives LEDs locally. Serialized scene state belongs to
  simulation; workbench frames are observed electrical output.
- TCP 5005 and UDP 5005 are different services. HTTP 5653 is the bulk update
  and package service.
- A browser **simulator** executes MicroPython WASM. A remote browser watching
  the **workbench** drives a physical board through a gateway.
- A maintenance command crosses serial; the rotor subsequently pulls its
  files over Wi-Fi/HTTP after rebooting into update mode.

The one-input trace on slide 12 connects these separate component views.
Keep returning to it when explaining audio and simulation substitutions.

## Packet details worth preserving

The accompanying reference records fields, port numbers and exact source
locations. Keep these details consistent when editing slides:

- Input packets are `2A joy1 joy2 extra`. Receivers read three fixed-position
  data bytes and retain the latest complete state. Discrete commands queue.
  The console host can send on changes; a constant packet cadence is not a
  protocol guarantee.
- Public **VS2 API revision 2** and **scene payload version 3** are separate
  version numbers. The current encoder/decoder supersede the old first-version
  packet table in the host-protocol document.
- The current Makefile provisions **30 MHz SPI**; older workbench prose says
  20 MHz. Actual values live in per-board NVS.
- The transfer buffer is **444 bytes**, but the strip has **107 physical
  LEDs**, with the centre intentionally shared by the two arm views.
- Core 0's actual loop both serves columns and projects when slack permits.
  A stale comment describes a separate core-1 renderer. MicroPython runs on
  core 1; the deck follows code and the single-task correction.
- UDP preview tolerates stale/missing chunks. USB acceptance capture adds a
  locked snapshot and CRC32. Neither is interchangeable with `frame_rgb`.
- Ordinary sound assets remain on the host. Console chip logs are synthesized
  there or in the remote browser; they are not raw PCM over the rotor UART.
- Original Ventilagon is a linked C module. Heavy Retro-Go apps boot separate
  app partitions. Normal native return targets `micropython`, not `factory`.

## Evidence and remaining author questions

The architecture is pinned to VSDK `451941f`, inspected October 18, 2026.
No firmware is flashed as part of slide verification. Audio and game-package
documents explicitly retain real-hardware validation work; the talk describes
the implementation and keeps that scope visible in its notes.

The author-owned historical gaps are limited to the short evolution slide:
was 2012 an idea or working-hardware year, when did the slip ring replace
batteries/Wixel, and which physical revisions are in use today? Existing
material establishes the 2013 experiment, 2015 game and documented present-day
target without resolving those questions. No personal story, event gallery
or inferred motivation is needed to fill them.

## Presenting and editing

Arrow keys or Space advance. Shift + Space goes back, `S` opens speaker view,
`F` toggles fullscreen and `Esc` opens the overview. The deployed preview
contains the rendered notes, source map and protocol reference.

For the slide deck alone, no Jekyll installation is needed:

```sh
python3 -m http.server 8000
```

Open `http://localhost:8000/presentations/architecture/`. Serve over HTTP:
Reveal fetches `slides.md`, which can be blocked through `file://`.
The document views require the normal Jekyll build; the existing pull-request
workflow renders them without installing Ruby locally.

Edit `slides.md` for content, `theme.css` for this deck's layout and `deck.js`
for Reveal settings. `---` separates slides and `Notes:` starts speaker notes.
All claims have `[Sources]` blocks in those notes. The diagram boxes and
transport labels are editable HTML/CSS. Reveal and the shared theme remain in
`../making-games/`; the cover photograph is reused from its assets.

The [print view](./?print-pdf) produces one page per slide. Print landscape,
with background graphics and no margins.
