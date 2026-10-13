---
layout: presentation-page
title: Presenting “Making games for Ventilastation”
lang: en
---

[Open the slides](./) or use the [reading view with notes](handout.html).

This English talk is for game developers attending Overkill Festival 2026. It
builds **Dream Garden**, a small shared garden inspired by Sickhouse's
[Dream No Return theme](https://www.sickhouse.nl/festival/dream-no-return-2026).
The walkthrough lasts 40 minutes, including two desktop demonstrations.
Questions get five minutes. Every slide has a duration and cumulative time cue.

## Presenting

- Arrow keys or Space advance. Shift + Space goes back.
- `S` opens the speaker view with notes, the next slide and a pacing timer. Allow the speaker popup if your browser blocks it.
- `F` toggles fullscreen. `Esc` opens the overview. `?` shows keyboard help.
- Slide anchors let you bookmark demonstration checkpoints.

The slides, library, highlighting and images come from this website. External
links provide references rather than dependencies for the presentation.

## Before the talk

Follow the [desktop setup]({{ '/docs/guides/desktop.html' | relative_url }}) in a
current SDK checkout. During branch review, use `feat/dream-garden-clouds` or
extract the [complete game download](examples/dream-garden.zip) at the SDK root.
The download creates `games/demos/dream_garden/` and includes the source, packed
PNGs, YAML, menu icon, MP3s, artwork provenance and rebuild recipes.

Run the finished game:

```sh
./vs-emu.sh --game demos.dream_garden
```

Windows uses `vs-emu.bat --game demos.dream_garden`. Keep its terminal visible for
tracebacks. Test two gamepads if available. One keyboard also works:

| Action | Player 1 | Player 2 |
| --- | --- | --- |
| Steer | A / D | Left / Right arrows |
| Begin / join / slow seeds | Space | Numpad 0 |
| Rest | B | Numpad 1 |
| Toggle audio | N | Numpad 2 |
| Exit | 1 or M | Numpad + or 3 |

Sound starts on. Check the room's volume before launching; N toggles music and bloom sounds together, with a two-second NOISY/QUIET notice that slides out past the rim. Use 1 or M to leave a demonstration. F1 shows the keyboard layout.

## First demonstration

Create `games/myname/mygame/`, put [the starter](examples/first_game.py) in
`code/mygame.py`, and copy `dreamer.png` and `menu.png` from Dream Garden. Use a
YAML file that lists only the dreamer:

```yaml
palettegroups:
  garden:
    - strip: dreamer.png
      frames: 8
```

Save it as `images/__images__.yaml`. Add `meta.json`:

```json
{"api": "vs2", "api_revision": 2, "title": "My Garden"}
```

Run `./vs-emu.sh --game myname.mygame`. Steer across the angular seam and show
that opposite inputs cancel. The slide at `#/first-demo` has a matching renderer
capture if you need to present without the emulator.

## Finished demonstration

Run `demos.dream_garden` again. Start with A, catch a seed to grow a flower, and
let another pass harmlessly. Invite a second person to join. Either player can
hold A to slow the seeds while clouds and planted flowers keep their normal pace. Point out RELAX, fluffy clouds in varied sizes, seeds normally moving 15% slower than clouds and slowing further under A, and the much slower inward flower drift.
Plants follow current movement; after stopping, the first follows that direction, then later catches alternate sides until movement resumes. Seeds pulse independently at random.
Toggle the quiet audio and show NOISY/QUIET holding for two seconds before sliding out. RELAX slides out when A is released. B chooses a still rest scene that keeps the
flowers. A begins a new garden. Y/Back returns to the launcher.

Keep [the finished source](examples/dream_garden.py) open at `build`, `update`
and `move_seeds`. `#/finished-demo` shows the resting scene if a live demo is
unavailable. The display geometry slides use the same game's actual sprites
and font through the SDK desktop renderer. The general API tutorial remains a
separate Trench Run walkthrough.

## Editing, hosting and printing

Edit `slides.md`. `---` separates slides, `Notes:` starts speaker notes, and
`data-timing` gives seconds. Keep note ranges and the 45-minute total consistent.
The website's usual Jekyll and Pages build serves the deck at
`/presentations/making-games/`, including project-site prefixes. The deck keeps
its dark theme in slide, reading and speaker views.

[Open the print layout](./?print-pdf) in Chrome or Chromium and print landscape,
with no margins and background graphics enabled. The reading view is also
printable and includes notes.

## Sources and assets

The previous [Ventilastation Jam 2025 deck](https://docs.google.com/presentation/d/1gfKrzKq1-QdnFjiBYQB6Z456wWDf1JxnY42-vLq9Bws/edit)
inspired the subject order. The current SDK documentation supports the API and
display explanations. The [festival site](https://2026.theoverkill.nl/) and
Sickhouse's theme announcement informed the new game direction.

Cover and console photographs come from this website. Circular-coordinate and
scene-lifecycle diagrams come from the existing SDK documentation. New game
captures come from the SDK desktop renderer. The [artwork and sound record](examples/artwork.html)
contains the built-in image generation prompt and the original tone recipes.
The source and download accompany the slides. Reveal.js 6.0.2 is vendored with
its MIT license and version record in `vendor/reveal/`.

## Browser checkpoints

Code examples have a **Run this checkpoint** button. It opens the browser
emulator with a cumulative version of the game at that slide,
using the same packed assets as the desktop game. The stages are steering,
poses, pools, timers, flowers, tiles, scrolling, HUD, scenes, shared play and
audio. The early stages start directly; from the scenes checkpoint onward,
press Space (A) at the title. A/D steer, Space relaxes time when that mechanic
appears, B rests after scenes are introduced, and N toggles the final audio.
Use the browser’s Back action to return to the same slide, or open the link
in another tab using your browser’s usual modifier key.
Reload the checkpoint URL to start fresh. Keep the desktop setup ready as a
backup for poor network conditions.
