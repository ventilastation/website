---
layout: presentation-page
lang: en
title: Dream Garden artwork and sound
---

[Game download and source](dream-garden-guide.html) · [Slides](../)

The files named below are in the complete game download.

# Artwork and sound sources

The built-in image generation tool created `source-atlas.png` for this game.
`prepare-atlas.cjs` crops its cells, swaps the two leaning poses, resizes with
nearest-neighbour sampling, snaps alpha to a binary mask and packs horizontal strips. It does not draw the
artwork. Run it with Node.js and the optional `sharp` asset-preparation package.
Install sharp at the SDK root with `npm install --no-save --package-lock=false sharp`,
then run `node games/demos/dream_garden/sources/prepare-atlas.cjs`.
Neither Node nor sharp is a game runtime dependency.

The generated sheet contains two dream creatures, golden seeds, four flower
species and sparse garden accents. Dreamers have four poses each. Flowers have
two frames each. The original fourth row is unused in this cloud experiment. Seeds are packed at 9 × 9 pixels: a subdued idle frame and
three brighter glow frames. Flying accents now use the separate cloud atlas described below. `images/steel8x8.png` is copied unchanged from the SDK's
`games/demos/tutorial_game/images/steel8x8.png`.

`make_audio.py` synthesizes the original bloom chime and a 32-second soft loop
from sine tones and encodes them with FFmpeg. Run it with host Python 3 and
FFmpeg to rebuild the two MP3s. These files follow the repository's GPLv3
license alongside the sample code. No external music or sampled recording is
used.

## Generation prompt

Create a production-ready transparent pixel-art SPRITE ATLAS for an experimental circular arcade game called Dream Garden. Exact layout: EIGHT equal columns and FOUR equal rows, a 2:1 horizontal image. Each cell contains one separate centered sprite with generous transparent padding. No visible grid lines, letters, numbers, labels, background, shadow beneath objects, or scene. Strict low resolution pixel art: chunky crisp square pixels, limited pastel mint/lavender/pink/amber palette with deep navy outlines, no antialiasing style or gradients. Intended to read at 19x19 pixels. ROW ONE all 8 cells: a tiny rounded dream creature with two eyes and soft leafy antennae. Cells 1-4 pink creature, neutral face, leaning left, leaning right, sleeping with closed eyes. Cells 5-8 same creature in mint blue, same four poses. ROW TWO cells 1-4: one floating golden seed/wisp in four subtle animation phases, simple bright core and a little tail; cells 5-8 entirely empty transparent. ROW THREE all 8 cells: four distinct dream flowers, TWO frames per flower with petals open slightly differently. Flower species: pink star blossom, mint fern blossom, lavender moon flower, amber glowing mushroom flower. ROW FOUR all 8 cells: eight tiny sparse dream garden accents on transparency: a mint root curl, a pink petal pair, a lavender crescent, three tiny amber stars, a blue sprout, a mint leaf, lavender bubbles, a single pink curl. All objects completely contained within their individual cells, exact consistent spacing. Cozy strange playful dream imagery for a festival about dreaming and rest. No spacecraft, weapons, robots, metal, UI, logos, or text. Export on genuine transparent background.

## Fluffy cloud experiment

The built-in imagegen tool generated a [separate six-cloud atlas](../assets/cloud-atlas.png).
The exact prompt is included as `sources/cloud-prompt.txt` in the game download.
`node games/demos/dream_garden/sources/prepare-clouds.cjs` packs two variants each
at 16 × 16, 32 × 16 and 48 × 32 pixels, cuts them into adjoining 16-pixel tiles
and produces an 18-frame strip. Binary alpha removes faint surrounding glow;
70% brightness keeps clouds subdued. Clouds use their own palette group.
Larger shapes occupy two cells or a 3 × 2 block, without gaps at cell boundaries.
The packer reverses source cell order to match the polar renderer’s tile
orientation; the map places the resulting frames row by row.
