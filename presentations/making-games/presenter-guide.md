---
layout: presentation-page
title: Presenting “Making games for Ventilastation”
lang: en
---

[Open the slides](./) or use the [reading view with notes](handout.html).

The talk is for experienced game developers. The main walkthrough takes 40 minutes, including two desktop demonstrations. Questions get the remaining five minutes. Each slide has a duration and a cumulative time cue in its speaker notes.

## Presenting

- Arrow keys or Space advance. Shift + Space goes back.
- `S` opens the speaker view with notes, the next slide and a pacing timer. Allow the presentation to open its speaker window if your browser blocks the popup.
- `F` toggles fullscreen. `Esc` opens the slide overview. `?` shows keyboard help.
- Slide URLs include an anchor, so you can bookmark a demo checkpoint or return to it after switching windows.

Everything needed to display the slides, including the presentation library, code highlighting and images, comes from this website. External links are references, not presentation dependencies.

## Before the talk

Set up the [desktop emulator]({{ '/docs/guides/desktop.html' | relative_url }}) in a local `vsdk` checkout. Run the finished example once:

```sh
./vs-emu.sh --game demos.tutorial_game
```

On Windows use `vs-emu.bat`. Leave the terminal visible beside the emulator so tracebacks are easy to find. Check your gamepad or arrow keys, Space and Page Down, and try the sound at the room's volume.

Prepare a second game named `myname.mygame` using [this complete starter](examples/first_game.py). The folder, metadata and image instructions are on the “A game is a folder” and “PNGs become indexed image strips” slides. The starter only needs `ship.png`, its `frames: 3` YAML entry, a `64 x 30` menu icon and `meta.json`.

For the first demonstration, run:

```sh
./vs-emu.sh --game myname.mygame
```

For the second, run `demos.tutorial_game` again. Show the title, steer, avoid an enemy, collide, restart and point out the best score. The [finished source](examples/trench_run.py) accompanies this deck and matches the SDK tutorial at commit `647670e`.

If the emulator is unavailable during the talk, the two checkpoint slides have screenshots. Explain what the input and update code do using those images. A real console is welcome for the second demo, but the talk does not require one.

## Editing and hosting

Edit `slides.md` in this directory. `---` separates slides and `Notes:` starts the speaker notes. Keep `data-timing` in seconds and the notes' time ranges consistent when changing the pacing. The notes include links to the source material.

Jekyll builds the presentation at `/presentations/making-games/`. It uses the website's usual build and Pages workflow, including project-site prefixes. No additional server or JavaScript build step is needed. Run the website's Jekyll build and serve the generated directory over HTTP to preview it locally.

## Printing

Open [the print layout](./?print-pdf) in Chrome or Chromium and print to PDF, with landscape orientation, no margins and background graphics enabled. The [reading view](handout.html) is also printable and includes the notes.

## Sources and assets

The previous [Ventilastation Jam 2025 deck](https://docs.google.com/presentation/d/1gfKrzKq1-QdnFjiBYQB6Z456wWDf1JxnY42-vLq9Bws/edit) inspired the subject order. This deck uses the current VS2 tutorial rather than that deck's older API examples.

Tutorial diagrams, screenshots and example code come from [the SDK at `647670e`](https://github.com/ventilastation/vsdk/tree/647670e015da1fe5b7f1cbae869607566a2b3911/docs/vs2). The cover and console photograph come from this website. Reveal.js 6.0.2 is vendored with its MIT license and version record in `vendor/reveal/`.
