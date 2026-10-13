---
layout: presentation-page
lang: en
title: Dream Garden
---

A small cooperative game for the Ventilastation talk at Overkill Festival 2026.
The festival's [Dream No Return theme](https://www.sickhouse.nl/festival/dream-no-return-2026)
inspired a garden whose players can choose a slower pace. This is an original
sample game, not a festival commission or an official festival game.

[Download the complete game](dream-garden.zip). While these changes are under review, use the SDK branch `feat/dream-garden-clouds`. Extract the archive at the root of that SDK checkout to create `games/demos/dream_garden/`. The source, packed assets, audio and rebuilding recipes are included, along with `tests/test_dream_garden.py` so the checks below also work when installing into a current SDK checkout. After merging, the same archive works in an updated main checkout.

[Small first-game starter](first_game.py) · [Back to the slides](../)

[Play the finished game in the browser]({{ '/emulator/?game=demos.dream_garden' | relative_url }}).

## Playing on the desktop

From the SDK root, after following the [desktop setup]({{ '/docs/guides/desktop.html' | relative_url }}):

```sh
./vs-emu.sh --game demos.dream_garden
```

Windows uses `vs-emu.bat --game demos.dream_garden`.

| Action | Controller | Player 1 keyboard | Player 2 keyboard |
| --- | --- | --- | --- |
| Begin / join | A | Space | Numpad 0 |
| Drift around the rim | Left / Right | A / D | Left / Right arrows |
| Slow the seeds | Hold A | Hold Space | Hold Numpad 0 |
| Rest and keep the flowers on screen | B | B | Numpad 1 |
| Toggle the quiet lullaby and bloom sound | X | N | Numpad 2 |
| Return to the launcher | Y / Back / Home | M / 1 / Escape | Numpad 3 / + / Escape |

The garden starts empty. Catch a golden seed to plant a flower at the catching
player’s depth, displaced by 75% of the player’s width. While moving, catches
plant in the current movement direction. After stopping, the first catch uses
that direction, then later catches alternate sides until movement resumes.
Each player has an independent sequence; opposite inputs count as stopping.
Before the first movement, the first catch defaults to the left.
Flowers drift inward at 8% of normal seed speed and disappear at the centre.
Smaller, subdued golden seeds occasionally pulse with a randomly triggered glow.
Missing a seed has no penalty. A second
player joins by steering or pressing A, using an already reserved mint dreamer.
Either player can slow the seeds. Clouds, planted flower drift and flower
animation keep their normal pace. New spawn intervals also lengthen, after the pending seed deadline.
Flowers gradually replace the oldest ones when the garden fills up.

There is no death, score, countdown or difficulty ramp. Watching is welcome. Music and bloom sounds start on. X toggles both, showing NOISY or QUIET
for two seconds before the text slides outward past the rim over 450 ms.
Another toggle resets the position and restarts the notice. B stops the music and keeps the current flowers in a still garden.
A starts a new garden from the Rest scene.

![The finished garden begins empty, with a pink dreamer below the clouds](../assets/garden-start.png)

## How the example works

`code/dream_garden.py` contains the whole game. `main()` returns Title, which
switches to Garden. Garden reserves its graph in `build()` and changes existing
objects in `update()`. A collision grows a flower instead of ending a run.
Pools cap seeds at 16 and flowers at 24, with explicit recycling for flowers.
The second player costs one reserved sprite even before joining.

The Garden graph uses **42 sprites, 3 tilemaps, 3 layers and 5 image strips**.
The flower pool counts toward that cost even when its slots are hidden. The
lower layer draws flowers first and players above them. The middle layer draws
six subdued fluffy cloud shapes, followed by 9-pixel golden seeds. Clouds
occupy 1 × 1, 2 × 1 or 3 × 2 tile cells, packed at 16 × 16, 32 × 16
and 48 × 32 pixels. Clouds keep scrolling at 0.45 depth units per tick. Seeds move 15% slower
by default (0.3825), and slow to 0.102 while relaxing. Seeds always paint
above clouds, including when their shapes overlap.
The top HUD shows RELAX while A is held, then slides it out on release,
plus temporary audio feedback.
Both flips keep the top text upright.

The full CP437 font comes from the existing tutorial example. PNGs and YAML
compile into a generated image ROM. MP3s stay on the emulator host or console
base and never go into the rotor ROM. The sample follows the repository's GPLv3
license. [Artwork sources and rebuilding](artwork.html) record the new art and
original sound synthesis. The general SDK tutorial remains a separate example.

## Build this garden step by step

Each stage is a complete, cumulative source file inside the download at
`code/checkpoints/`. The slides explain the changes and launch the matching
version in the web emulator. The last stage matches `code/dream_garden.py` exactly.

| Stage | Adds |
| --- | --- |
| 01-steering | One pink dreamer moving around the rim |
| 02-poses | Leaning and sleeping poses |
| 03-pools | Reserved seed and flower slots |
| 04-timer | Periodic random seed spawning |
| 05-flowers | Collisions, directional planting and inward flower drift |
| 06-tiles | Fluffy clouds in the middle layer, behind seeds |
| 07-scroll | Steady scrolling clouds, slower outward seeds |
| 08-hud | Seed-only RELAX and a label that slides out |
| 09-scenes | Title and voluntary rest, preserving flowers |
| 10-shared | A second player, independent planting sequences and random seed glow |
| 11-audio | Default-on lullaby and bloom sounds, timed NOISY/QUIET notices |

A new garden starts without flowers. The planting direction follows movement,
then alternates after stopping. Every stage keeps the same packed artwork,
with unused strips available for the later steps.

## Checks

From the SDK root:

```sh
python3 -m unittest discover -s tests -p test_dream_garden.py
mpy-cross games/demos/dream_garden/code/dream_garden.py -o /tmp/dream_garden.mpy
```

The tests exercise seam collisions, both controllers, shared slow time, safe
pool exhaustion, long play, default-on audio and timed toggle feedback, voluntary rest and the exit path.
