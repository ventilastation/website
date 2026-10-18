---
layout: presentation-page
title: Presenting Ventilastation's architecture
lang: en
presentation_root: /presentations/architecture
---

[Open the slides](./) · [Reading view with notes](handout.html) · [Sources](sources.html)

This first draft has **24 slides and 30 minutes of speaking time**. It assumes
an English-speaking technical audience interested in how the hardware and
software evolved. Questions follow the timed talk. These defaults can change
when the audience, language and demo preferences are confirmed.

The central idea is that the rotor/base boundary survives several generations,
while clearer software boundaries make it possible for more people to build
games. The history leads into the current architecture rather than becoming a
separate autobiographical talk.

## Pacing

| Elapsed time | Slides | Purpose |
| --- | --- | --- |
| 0:00–2:30 | 1–3 | Show the console and explain a display made through motion |
| 2:30–8:50 | 4–8 | Origins, the seven-LED prototype, and the 2015 Arduino architecture |
| 8:50–14:50 | 9–13 | ESP32/MicroPython, the desktop emulator, the C port, VSDK and game jams |
| 14:50–20:15 | 14–16 | Current physical layout, timing deadlines and VS2 scene ownership |
| 20:15–27:00 | 17–21 | Assets, browser runtime, audio, native firmware and OTA |
| 27:00–30:00 | 22–24 | Workbench evidence, shared native code and the closing argument |

Each slide has a `data-timing` duration in seconds and an elapsed-time cue in
its speaker notes. Their sum is 1,800 seconds. The notes are speaking prompts,
not a word-for-word script; give the current timing slide its full two minutes.

If the slot includes five minutes of questions, shorten the talk by five
minutes: reduce the opening by 30 seconds; the origin and 2015 section by
90 seconds; the 2023/game-jam examples by 60 seconds; and the asset, browser,
native-firmware and workbench explanations by 30 seconds each. Rehearse that
version and update the note cues and `totalTime` together. A live demo also
needs an explicit time allocation; the present deck does not depend on one.

## Questions for Alejandro

These are gaps in the available evidence, not facts to improvise on stage.

1. **Audience and purpose:** who is attending, and how deep should the talk go
   into embedded implementation versus game development?
2. **Language and slot:** English or Spanish? Does 30 minutes include questions
   or a live hardware/emulator demonstration?
3. **The 2012 starting point:** was there working hardware in 2012, or was this
   the inspiration/idea year? The earlier talk dates the PyCamp prototype to
   2013 and Super Ventilagon to 2015; the game repository begins in May 2015.
4. **The slip-ring transition:** when did it replace the rotating batteries
   and Wixel link, and what experience prompted it? The 2019 component list
   still has a power bank and Wixel. Slip-ring assembly documentation was
   committed in April 2025, which only establishes a latest possible date.
5. **The installed machines:** which physical revisions are still in use, and
   how do processor, LED type, base, motor and power arrangement differ? Board
   configuration presets exist, but they are not a deployment inventory.
6. **Experience on the spinning console:** which of VS2, Voom, console
   emulators, OTA and remote testing have been used in real operation? The
   deck describes implementation and does not infer deployment from a merge.
7. **Photo attribution:** who took the PyCamp prototype and early fan photos?
   The earlier talk credits many photos collectively to Facundo Batista under
   CC-BY-NC, without mapping that credit to individual assets.

Pending answers, the visible slides distinguish the 2012 inspiration,
2013 experiment, and 2015 game. They give no invented date for slip-ring
adoption and describe today's hardware as the documented SDK target.

## Technical details to preserve

- **107 LEDs is physical; 256 × 54 is logical.** Two 54-position arms share
  the central LED. The Arduino game's six-sector board is a different thing.
- **600 RPM is not a game frame rate.** At that speed, one revolution is
  100 ms and one of 256 angular bins is about 391 µs. Those are calculated
  timing budgets, not newly measured performance results.
- **Core 0 currently projects and serves the image.** The actual
  `coreTask()` does column service and projects into a back buffer when there
  is slack. A stale source comment describes a separate render task on core 1;
  the current loop and July 23 fix take precedence. MicroPython runs on core 1.
- **Sealing controls render objects.** It does not prevent all Python
  allocations or guarantee zero garbage collection.
- **Audio stays on the host.** Sprite ROMs contain graphics and palettes.
  Ordinary games and Doom send clip commands; the native chip bridge sends
  register logs for host synthesis.
- **Native paths differ.** Super Ventilagon is linked C code inside the
  MicroPython firmware. Retro-Go/Doom apps boot other flash partitions.
- **Factory is permanent recovery.** Normal Python games boot the
  `micropython` partition. Native exit also returns there.
- **Bench evidence has a scope.** Timing and LED-byte checks do not measure
  mechanical balance, motor temperature or the audience's visual experience.

## Presenting and editing

Arrow keys or Space advance; Shift + Space goes back. `S` opens the speaker
view, `F` toggles fullscreen and `Esc` opens the overview. Serve the repository
over HTTP rather than opening the HTML through `file://`: Reveal fetches
`slides.md`.

```sh
python3 -m http.server 8000
```

Open `http://localhost:8000/presentations/architecture/`. The slides use only
local scripts, fonts and image assets. Internet access is needed only to
follow external source links. The reading view, this guide, and sources page
use the repository's normal Jekyll build, described in `CONTENT.md`.

Edit `slides.md` for content, `theme.css` for presentation-specific styling,
and `deck.js` for Reveal settings. `---` separates slides; `Notes:` begins
speaker notes. Sources stay inside `[Sources]` blocks in the notes. Reveal and
the base theme are reused from `../making-games/`, so keep those shared files
when copying this talk. Historical pictures remain in `../../dump2024/`.

For printing, open [the print view](./?print-pdf) in Chromium and print
landscape with background graphics and no margins. The handout is also
printable. A PDF or PowerPoint export is not needed to present this version.

## Verification performed

The 24-slide deck was rendered in headless Chromium and every slide was
visually inspected. Checks covered title wrapping, content bounds, image
loading, source presence and the 30-minute total. The print layout was checked
separately. No firmware was flashed and no new claim of hardware acceptance
or audio validation is made. Full Jekyll rendering requires Ruby/Bundler,
which were unavailable in the preparation environment.
