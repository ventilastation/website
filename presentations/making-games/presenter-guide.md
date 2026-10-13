---
layout: presentation-page
title: Presenting Ventilastation at COLLIDERS Meet-up – Circular Arcades
lang: en
---

[Open the slides](./) or use the [reading view with notes](handout.html).

This English talk has two parts: a **12-minute introduction for everyone** and
**15 minutes of coding**. Questions and open play follow the timed 27 minutes.
The event is Sickhouse’s [COLLIDERS Meet-up – Circular Arcades on October 14, 2026](https://www.sickhouse.nl/events/colliders-meet-up-circular-arcades).

## The introduction

Introduce Cybercirujas and its reuse of technology, then explain the fan display
through motion, arxels and transformed artwork. Show Super Ventilagon and Vyruss
as my sample games, then Senile command, Vasura Espacial and Tincho el Carpincho
as past jam creations. Explain two-player controls and audio, then scenes
and the visual pieces of a game without showing code. Close with the
[Ventilastation × The Overkill Jam](https://itch.io/jam/ventilastation-overkill-jam).
It starts October 14, and its page lists November 11 as the submission end date.
The resulting games will appear at [The Overkill, November 26–29](https://www.sickhouse.nl/events/the-overkill-festival-2026).
Artists, musicians, writers and playtesters can contribute alongside programmers.

For a ten-minute introduction, shorten the two game-gallery slides and the
scene examples. For fifteen minutes, allow questions or a brief hardware
interaction at the controller slide. The coding section stays fifteen minutes.

## The coding section

Keep the focus on the differences of this console: angle and depth, the angular
seam, a reserved display graph, curved indexed art, draw order and HUD text
orientation. Setup, timer details, glow implementation, budget tables and heap
analysis stay in the linked guides. The final game still includes those features.

There are exactly three launch buttons, each opening a new tab:

| Part | Slide | Runnable source in the game download |
| --- | --- | --- |
| One creature around the rim | `#/first-game-code` | `code/checkpoints/01-steering.py` |
| Catching and planting | `#/planting` | `code/checkpoints/05-flowers.py` |
| Completed shared cloud garden | `#/finished-demo` | `code/checkpoints/11-audio.py` |

The last file matches `code/dream_garden.py` exactly. Earlier fine-grained
checkpoints remain in the SDK and complete download, but this talk uses only
these three versions. Reserve about one minute of live play for each of the
first two parts and two minutes for the completed game. Return to the
presentation tab after each launch.

## Before the talk

Use a current SDK main checkout and follow the [desktop setup]({{ '/docs/guides/desktop.html' | relative_url }}).
Dream Garden is included, or extract the [complete game download](examples/dream-garden.zip)
at the SDK root. Prepare dependencies before presenting.

```sh
./vs-emu.sh --game demos.dream_garden
```

Windows uses `vs-emu.bat --game demos.dream_garden`. Keep the terminal available
for tracebacks. The browser launches are quick demonstrations; the desktop
emulator is the local development loop. Test both physical controllers and the
room volume beforehand. Music and bloom sounds start on.

| Action | Player 1 keyboard | Player 2 keyboard |
| --- | --- | --- |
| Steer | A / D | Left / Right arrows |
| Begin / join / slow seeds | Space | Numpad 0 |
| Rest | B | Numpad 1 |
| Toggle audio | N | Numpad 2 |
| Exit | 1 or M | Numpad + or 3 |

Release the start press before holding A to relax. Show that only seeds slow;
clouds and flower animation stay steady. Stop after moving and catch successive
seeds to demonstrate alternating planting sides. N shows NOISY or QUIET for two
seconds before the notice slides out. B keeps the flowers in a still Rest scene.
A begins another dream. F1 displays keyboard help.

## Presenting, hosting and editing

Arrow keys or Space advance. Shift + Space goes back. `S` opens the speaker
view with notes and timing. `F` toggles fullscreen and `Esc` opens the overview.

Edit `slides.md`. `---` separates slides and `Notes:` starts speaker notes.
`data-talk-part` separates introduction and coding, and `data-timing` records
seconds. Keep the note cues, 12-minute introduction and 15-minute coding totals
consistent. The website serves the dark deck, notes and reading view at
`/presentations/making-games/`, including project-site prefixes.

[Open the print layout](./?print-pdf) in Chromium and print landscape, without
margins and with background graphics enabled. The reading view is printable too.

## Sources and images

The Cybercirujas and vs_gameon photos were supplied by Alejandro J. Cura
from his local collection.
The [UNQ account](https://agencia.unq.edu.ar/?p=7125) supports the collective’s
repair, recirculation and knowledge-sharing work. The official jam and Sickhouse
pages support the event information. Individual game source folders are linked
in their slides’ notes. The earlier Ventilastation Jam 2025 deck inspired the
subject, while the current SDK supports the technical details.

All game screenshots and display examples use the WebGL backend with glow.
Original photos, artwork atlases and the coordinate diagram keep their sources.

```sh
python3 tools/presentation-scenes.py --sdk vsdk --out /tmp/garden-scenes.json
node tools/capture-presentation.mjs vsdk /tmp/garden-scenes.json
node tools/capture-presentation-catalog.mjs
```

Run from the website repository after `make publish`, with Playwright installed.
Set `CHROMIUM` to an installed Chrome executable if necessary. Both capture
scripts require WebGL. `assets/captures.json` and `assets/catalog-captures.json`
record backend and image hashes. The Garden examples use actual packed assets;
the game gallery captures real games running in the web emulator.
