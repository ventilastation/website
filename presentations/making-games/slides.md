<!-- .slide: id="making-games" class="cover" data-background-image="assets/cover.jpg" data-background-opacity="0.2" data-timing="30" -->

# Making games for Ventilastation

Dream Garden at Overkill Festival 2026

Alejandro Cura <!-- .element: class="byline" -->

Notes:
**0:00–0:30.** We will make a small shared garden for a display with no corners. The audience knows games, so spend the time on the unusual screen, a few API rules and the design choices that make this game worth playing. The theme for Overkill 2026 is Dream No Return. Our example lets people drift, grow flowers and choose a slower pace. Use the desktop emulator and the current Ventilastation API, VS2.

Sources: [Sickhouse's 2026 theme](https://www.sickhouse.nl/festival/dream-no-return-2026), [the festival](https://2026.theoverkill.nl/), [Ventilastation](../../en/). Cover photograph: this website's `images/banner.jpg`.

---


<!-- .slide: id="console" data-timing="60" -->

## A console built around a fan

<div class="split">
<div>
<p>Spinning LEDs form the display.</p>
<p>An <strong>ESP32-S3</strong> runs your MicroPython game.</p>
<p>The project is open source and open hardware.</p>
</div>
<img src="assets/console.jpg" alt="Ventilastation's LED arm and electronics mounted inside a fan">
</div>


Notes:
**0:30–1:30.** Keep the hardware introduction short. Persistence of vision turns a rotating LED arm into a disc. The current game target is an ESP32-S3, with roughly 8 MB of RAM shared by the interpreter, heap and image strips. One core handles the game and another handles display work. Audio plays on the base station, not on the rotor. The photo shows a Ventilastation build, not a board identification guide. Game developers can work on a computer without owning or building the console.

Sources: [Tutorial introduction](../../docs/vs2/tutorial/index.html), [website](../../en/). Photograph: this website's `images/pic01.jpg`.

---


<!-- .slide: id="display-in-time" data-timing="75" -->

## The screen is drawn over time

<div class="split">
<div>
<p>A moving LED arm paints each angular column at a different instant.</p>
<p><strong>Persistence of vision</strong> joins those columns into a disc.</p>
<p>The game tick and physical rotation are separate clocks.</p>
</div>
<video src="../../images/banner.mp4" poster="assets/cover.jpg" controls muted loop playsinline data-autoplay aria-label="Ventilastation's real circular LED display in motion"></video>
</div>


Notes:
**1:30–2:45.** A conventional panel has physical pixels distributed over a surface. Ventilastation moves a line of LEDs through that surface and changes their colours at each angle. Your eye integrates the emitted light over a rotation. The output serves 256 angular columns, each with 54 radial LED samples. The renderer prepares polar framebuffers, and the output serves ready columns independently of the 30 ms game tick. Motor speed does not set your update rate. This is why physical brightness, motion and display deadlines matter even when a desktop image looks correct. The clip shows the real display. If video cannot play, the poster still gives the physical context.

Sources: [Physical display and renderer](../../docs/vs2/tutorial/index.html), [geometry](../../docs/vs2/tutorial/display.html). Video: this website's `images/banner.mp4`.

---

<!-- .slide: id="wedge-pixels"  data-timing="75" -->

## The pixels form wedges

<div class="split">
<div>
<p>Each column spans an angle, rather than a fixed horizontal distance.</p>
<p>The same angular step is <strong>wider at the rim</strong> and narrower near the centre.</p>
<p>Moving around the disc also rotates the artwork.</p>
</div>
<img src="assets/display-angles.png" alt="The same dream creature at four angles, with its leafy antennae pointing inward at every position">
</div>

Notes:
**2:45–4:00.** Here are four copies of our dream creature at the same depth. Their orientation follows the disc. Their antennae point inward rather than staying upright on a rectangular screen. Angular cells get physically narrower near the centre, while the LED bar determines radial spacing. A constant angular velocity covers different physical distances at different radii. Put critical text near the rim and decide whether movement means angle or depth. A garden arranged around the disc lets people tend the whole circumference.

Source: [Circular geometry and sprite orientation](../../docs/vs2/tutorial/display.html). Image: the emulator’s WebGL display backend with Dream Garden's actual assets.

---

<!-- .slide: id="dream-garden"  data-timing="75" -->

## Dream Garden

<div class="split">
<div>
<p>Drift around the rim and catch seeds to grow flowers.</p>
<p>Either player can hold A to <strong>slow the shared seed flow</strong>.</p>
<p>Passing seeds do no harm. Watching is welcome.</p>
<p class="caption">Inspired by Dream No Return</p>
</div>
<img src="assets/dream-garden.png" alt="Two dream creatures on the rim, golden seeds above blue-gray clouds and pink, mint and lavender flowers drifting inward">
</div>

Notes:
**4:00–5:15.** Overkill's 2026 theme gives us a design prompt about dreaming and rest, with chapters including Time, Shape Shifting, Escape and Lullabies. This game is our response. A pink dreamer catches seeds. A mint friend can join. A catch creates a flower and a miss simply passes. Holding A slows the shared seed flow. Clouds keep moving at their normal pace. The garden starts empty, and flowers drift slowly inward after planting. There is no score, death, countdown or difficulty ramp. B chooses a still resting scene. Ask the audience what happens when time becomes something players can share rather than a resource they must beat. Then move straight into making it.

Sources: [Sickhouse's theme](https://www.sickhouse.nl/festival/dream-no-return-2026), [finished game source](examples/dream_garden.py). Screenshot: a populated game state rendered by the emulator’s WebGL display backend.

---

<!-- .slide: id="desktop"  data-timing="75" -->

## The desktop development loop

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

```sh
git clone https://github.com/ventilastation/vsdk.git
cd vsdk
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt

./vs-emu.sh --game demos.dream_garden
```

Edit local files, rerun, watch the terminal.

Windows uses `vs-emu.bat`. <!-- .element: class="caption" -->

Notes:
**5:15–6:30.** Prepare dependencies before the live demonstration. The setup guide covers Linux, macOS and Windows, including MicroPython and FFmpeg. The desktop host uses CPython, while game code runs in MicroPython. Do not initialize the Retro-Go firmware submodule just to make a game. The terminal shows game prints and tracebacks. The emulator rebuilds changed image ROMs at launch. Dream Garden is included in the SDK checkout, or can be installed from the complete game download. WASD are the directions, Space is A, B is B, N toggles audio and 1 or M exits. F1 shows the keyboard layout. Two gamepads or the second keyboard controls support shared play. The Run this checkpoint button opens the finished game in the browser.

Sources: [Desktop setup](../../docs/guides/desktop.html), [complete Dream Garden download](examples/dream-garden.zip), [game instructions](examples/dream-garden-guide.html).

---

<!-- .slide: id="game-folder"  data-timing="75" -->

## A game is a folder

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=01-steering" data-checkpoint="01-steering">Run this checkpoint</a>

```text
games/myname/mygame/
  code/mygame.py
  images/dreamer.png
  images/__images__.yaml
  menu.png
  meta.json
```

```json
{"api": "vs2", "api_revision": 2, "title": "My Garden"}
```

`main()` returns a scene. The menu icon is 64 × 30 pixels.

Notes:
**6:30–7:45.** The code module has the same name as its game folder. Group and folder form the launch name, myname.mygame. The metadata explicitly declares the current API. The launcher discovers the folder without a central application list. Copy dreamer.png and menu.png from the downloaded sample, list only dreamer.png with frames: 8 in the starter YAML, and copy the starter source to code/mygame.py. The finished sample uses demos/dream_garden and code/dream_garden.py. The game download includes its code, images, YAML, icon, sound and source credits. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Your first game](../../docs/vs2/tutorial/first-game.html), [starter source](examples/first_game.py), [complete game](examples/dream-garden.zip).

---

<!-- .slide: id="sprite-atlas" data-timing="45" -->

## Dreamers, seeds, flowers and clouds

<div class="split">
<img src="assets/source-atlas.png" alt="Pink and mint dreamers, golden seed frames and four flower species on the original source atlas">
<img src="assets/cloud-atlas.png" alt="Six fluffy cloud shapes, packed at three sizes for the flying layer">
</div>

<p class="caption">Dreamers and flowers below. Clouds and seeds above.</p>

Notes:
**7:45–8:30.** Show the original artwork sheet before explaining its runtime format. The top row has four pink poses and the same four poses in mint for player two. Below are four seed frames, four flower species with two frames each, and eight sparse garden details. The source atlas was generated for this game and is included in the download. The preparation script crops its cells, corrects the leaning pose order, resizes them with nearest-neighbour sampling, makes alpha binary and packs horizontal strips. The fourth row is unused in this experiment; a separate six-cloud atlas supplies the flying layer. The dreamers become 19 × 19 pixel frames. Keep the artwork legible at that final size, especially on the moving physical display.

Source: [Artwork provenance and preparation](examples/artwork.html). Images: Dream Garden's original source and cloud atlases, included unchanged.

---

<!-- .slide: id="assets"  data-timing="60" -->

## PNGs become indexed image strips

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=01-steering" data-checkpoint="01-steering">Run this checkpoint</a>

<div class="split">
<div>
<pre><code class="language-yaml" data-trim>palettegroups:
  garden:
    - strip: dreamer.png
      frames: 8</code></pre>
<p>Equally sized frames, arranged horizontally.</p>
<p>256 colours per palette group.</p>
</div>
<img src="assets/strip-dreamer.png" alt="Four pink dreamer poses: awake, leaning left, leaning right and asleep">
</div>

Notes:
**8:30–9:30.** The console uses compiled strips rather than decoding PNGs during play. The full dreamer strip has eight 19-pixel frames, so it is 152 pixels wide. The picture shows its first four poses. The next four repeat those poses in mint for player two. YAML declares all eight frames. Related art shares a palette group. The full game adds seed.png (4 frames), flowers.png (8), clouds.png (18) in its own palette group, and steel8x8.png (256) in a text palette. Add these entries to __images__.yaml as you introduce each asset. The download includes the complete YAML. You can replace the packed PNGs with your own pixel art. Rerun the emulator after editing assets. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Image setup](../../docs/vs2/tutorial/first-game.html), [artwork provenance and preparation](examples/artwork.html). Image: the actual packed dreamer strip, cropped to player one's poses.

---


<!-- .slide: id="lifecycle" data-timing="105" -->

## A scene builds once per entry

![A scene builds its display graph, becomes sealed and closes on a transition](assets/scene-lifecycle.png) <!-- .element: class="wide-figure" -->

`build()` reserves the display graph.

`update()` changes the existing objects, every 30 ms.


Notes:
**9:30–11:15.** This is the main architectural rule. Create layers, sprites, pools, tilemaps and labels in `build()`. Returning from build seals the scene. Update can move, animate, show and hide them, but creating a new sprite there raises `SceneSealedError`. Structural budgets fail at scene entry rather than in the middle of a run. Build runs again whenever the scene is re-entered, and previous drawable handles are no longer valid. State that should survive belongs in `__init__`. A nominal tick is 30 milliseconds, about 33 updates per second. Slow updates delay the next tick rather than catching up lost time.

Sources and diagram: [Scene lifecycle](../../docs/vs2/reference/scene.html), [runtime constraints](../../docs/vs2/tutorial/index.html).

---

<!-- .slide: id="first-game-code" class="compact" data-timing="90" -->

## A complete first game

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=01-steering" data-checkpoint="01-steering">Run this checkpoint</a>

```python
import vs2
from vs2.controls import LEFT, RIGHT, joy1

class Game(vs2.Scene):
    def build(self):
        world = self.layer("world", projection=vs2.TUNNEL)
        self.dreamer = world.sprite("dreamer.png", y=0)
        self.dreamer.x = -(self.dreamer.width // 2)

    def update(self):
        steer = joy1.held(LEFT) - joy1.held(RIGHT)
        self.dreamer.x = (self.dreamer.x + steer) % vs2.display.width

def main():
    return Game()
```

Notes:
**11:15–12:45.** Read this as an engine interface rather than a Python lesson. Main returns the first scene. Build creates a TUNNEL layer and a sprite by image name. X is the sprite's edge, so subtracting half its width centres the dreamer on angle zero. Update reads stable controller levels. Left minus right gives a direction and cancels opposite inputs. Wrapping keeps the stored X bounded, and the renderer also handles images crossing the seam. This is complete code once the folder, assets and metadata exist. The download has a short docstring with installation instructions. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [First game](../../docs/vs2/tutorial/first-game.html), [circular display](../../docs/vs2/tutorial/display.html), [starter code](examples/first_game.py).

---

<!-- .slide: id="first-demo"  data-timing="75" -->

## First checkpoint: a creature you can steer

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=01-steering" data-checkpoint="01-steering">Run this checkpoint</a>

<div class="split">
<div>
<p><code>./vs-emu.sh --game myname.mygame</code></p>
<p>A / D drift around the rim.</p>
<p>Positive X turns left at the bottom.</p>
<p class="caption">Desktop demonstration</p>
</div>
<img src="assets/first-game.png" alt="A single pink dream creature at the bottom rim of the circular display">
</div>

Notes:
**12:45–14:00.** Switch to the prepared desktop starter. Hold left, cross the seam, then hold right. Show that opposite buttons cancel. Point out the terminal and source file, then return to the deck. The goal is to make the circular coordinate model tangible before adding rules. If the emulator is unavailable, use this real renderer capture and trace the position change aloud. It shows only the starter's one sprite. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Starter source](examples/first_game.py), [first-game instructions](../../docs/vs2/tutorial/first-game.html). Screenshot: actual game assets through the emulator’s WebGL display backend, running the actual steering checkpoint.

---


<!-- .slide: id="coordinates" data-timing="75" -->

## X is an angle. Y points inward.

![Circular coordinates: zero at the bottom, 64 at the left, 128 at the top and 192 at the right, with y growing inward](assets/display-axes.png) <!-- .element: class="figure" -->


Notes:
**14:00–15:15.** This is the main mental adjustment for developers used to rectangular screens. The logical display has 256 angular columns and 54 radial LEDs. X zero is the bottom, then 64 is left, 128 top, and 192 right. X wraps. Y zero is the outer rim, and positive Y goes inward. A sprite crossing the angular seam stays continuous. The physical width of an angular column decreases near the centre, so a rectangular image gets squeezed there. Use `vs2.display.width` and `.height` to read the geometry, but distinguish physical LED height from tunnel depth on the next slide.

Source and diagram: [The circular display](../../docs/vs2/tutorial/display.html).

---

<!-- .slide: id="projections"  data-timing="90" -->

## Layers choose the projection

<div class="split">
<div>
<p><strong>TUNNEL</strong><br>Y is depth, 0–255. Objects shrink inward.</p>
<p><strong>HUD</strong><br>Y is an LED index, 0–53.</p>
<p><strong>FULLSCREEN</strong><br>A centred image. X rotates it.</p>
</div>
<img src="assets/display-projections.png" alt="Dreamers at depths 0, 24 and 48 on TUNNEL at the top and at radial LED positions 0, 24 and 48 on HUD at the bottom">
</div>

Notes:
**15:15–16:45.** Choose a projection per layer. The finished Dream Garden uses two TUNNEL layers for the planted garden and flying objects, plus one HUD layer for text. These dreamers use Y values 0, 24 and 48 on TUNNEL above and HUD below. Decreasing tunnel depth moves a seed outward toward the players. HUD removes perspective scaling, though angular cells still narrow near the centre. FULLSCREEN draws a centred image whose X rotates it and whose Y follows the tunnel depth curve. It accepts sprites only. Layers paint in creation order, then drawables in creation order inside each layer. The lower layer draws flowers then dreamers; the middle draws clouds then seeds; the HUD draws last. Physical height 54 is not a tunnel off-screen threshold.

Source: [Projections and draw order](../../docs/vs2/tutorial/display.html). Image: actual dreamer assets in two scene layers through the emulator’s WebGL display backend.

---

<!-- .slide: id="animation"  data-timing="90" -->

## Movement and animation are property writes

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=02-poses" data-checkpoint="02-poses">Run this checkpoint</a>

<div class="split">
<div>
<pre><code class="language-python" data-trim>if sleeping:
    dreamer.frame = ASLEEP
elif direction > 0:
    dreamer.frame = LEFT_POSE
elif direction < 0:
    dreamer.frame = RIGHT_POSE
else:
    dreamer.frame = AWAKE</code></pre>
</div>
<div>
<p>Frame changes reuse the same sprite.</p>
<p>Flowers alternate between paired frames.</p>
<p>Golden seeds wait a random interval, then run a short glow sequence.</p>
</div>
</div>

Notes:
**16:45–18:15.** Property writes update existing renderer records. Frame picks artwork from the strip without creating a new sprite. Dreamers lean when moving and close their eyes while holding A. The finished helper takes a controller and a base frame, so the second player reuses the same behaviour. Flower pairs pulse using a steady clock. Early checkpoints cycle the seed frames together. The completed game gives every live seed its own random 90–240 tick wait, then plays frames 1, 2, 3, 2, 1, 0 for six ticks each. Reset the wait after a pulse and remove its state when the seed retires. This makes the seeds glow occasionally rather than flashing together. The final checkpoint includes that helper. Read available frame counts from sprite.image.frames. Frame and visibility are independent, useful for preparing the second player before joining. Invalid frames fail immediately. Think of the display as a retained graph whose properties change during play. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Sprites](../../docs/vs2/tutorial/sprites.html), [Dream Garden's steer helper](examples/dream_garden.py).

---

<!-- .slide: id="pools"  data-timing="90" -->

## Seeds and flowers have bounded pools

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=03-pools" data-checkpoint="03-pools">Run this checkpoint</a>

```python
# In build(), before creating the dreamer:
self.flowers = self.world.sprite_pool(
    "flowers.png", count=24, on_empty=vs2.RECYCLE
)
self.seeds = self.world.sprite_pool("seed.png", count=16)

# During play:
seed = self.seeds.spawn(x=100, y=160)
if seed is None:
    return  # this seed waits for another opportunity
```

A full flower pool reuses its oldest live flower.

Notes:
**18:15–19:45.** Reservation happens once in build. Flowers begin hidden, so the garden starts empty. Create the dreamer after the flowers to draw the player above the planted garden. The flying layer comes at the next step. Spawn reveals and positions a reserved sprite. A full seed pool returns None and drops that particular spawn. Flowers instead recycle their oldest live slot, so new growth continues without an ever-growing graph. Both choices are part of the design: the garden can keep changing, yet nothing demands a perfect catch rate. Pools count at their full reserved size, including hidden slots. Iteration visits live sprites and supports retiring the current one. Pooling renderer objects does not remove all unrelated Python allocations. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Source: [Sprite pools](../../docs/vs2/tutorial/pools.html), [sample source](examples/dream_garden.py).

---

<!-- .slide: id="spawn-timer"  data-timing="75" -->

## A timer controls the seed rhythm

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=04-timer" data-checkpoint="04-timer">Run this checkpoint</a>

```python
from urandom import randrange

# At the end of build():
self.call_later(self.spawn_ms, self.spawn_seed)

def spawn_seed(self):
    self.seeds.spawn(
        x=randrange(vs2.display.width), y=160
    )
    self.call_later(self.spawn_ms, self.spawn_seed)
```

A seed every 1.8 seconds. RELAX changes the gap later.

Notes:
**19:45–21:00.** The callback rearms itself with the current gap. This checkpoint uses 1800 ms. At the HUD checkpoint, held A changes spawn_ms to 4000 ms, but a seed that is already scheduled keeps its deadline. The next gap uses the slower rhythm. Seed movement reacts immediately in update. This avoids rebuilding or continually replacing timer records while a button is held. A full pool simply skips a spawn. Scene-owned timers disappear when the scene closes or suspends, so an old callback cannot plant into the rest screen. Timers suit occasional events, not the animation loop. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Scene timers](../../docs/vs2/reference/scene.html), [sample spawn_seed](examples/dream_garden.py).

---

<!-- .slide: id="collision"  data-timing="90" -->

## A collision grows a flower

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=05-flowers" data-checkpoint="05-flowers">Run this checkpoint</a>

```python
# In build(), in this order:
self.world = self.layer("world", projection=vs2.TUNNEL)
self.air = self.layer("air", projection=vs2.TUNNEL)
self.flowers = self.world.sprite_pool(
    "flowers.png", count=24, on_empty=vs2.RECYCLE
)
self.dreamer = self.world.sprite("dreamer.png", y=0)
self.seeds = self.air.sprite_pool("seed.png", count=16)

# In the seed movement loop:
if seed.overlaps(self.dreamer):
    self.bloom(seed)
```

Flowers below players. Flying seeds above both.

Notes:
**21:00–22:30.** Collision tests use axis-aligned bounds in a layer's circular coordinate system. They understand the angular seam, so a dreamer crossing zero can still catch a seed without a duplicate actor. They are not pixel-perfect physical tests on the fan. The actual loop first decreases seed depth, then checks either active dreamer. Bloom retires the seed and plants a flower at the dreamer’s depth. Its centre is displaced by 75% of the dreamer’s width. Moving catches plant in the current direction. After stopping, the first catch uses that direction, then later catches alternate sides. Moving again resets the sequence, separately for each player. Opposite inputs count as stopping. Before moving, the first catch defaults to left. The later planting slide shows the helper that implements this rule. Flowers drift toward the centre at only 8% of normal seed speed. A missed seed retires after passing the rim. The response changes the garden without ending play or recording failure. This is a small code change with a large effect on the experience. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Collision API](../../docs/vs2/tutorial/sprites.html), [Dream Garden's move_seeds and bloom](examples/dream_garden.py).

---
<!-- .slide: id="planting" class="compact" data-timing="75" -->

## Planting follows the player's movement

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=05-flowers" data-checkpoint="05-flowers">Run this checkpoint</a>

```python
# Movement resets the next planting side.
self.moving = bool(steer)
if steer:
    self.plant_side = steer

# In bloom():
centre = self.dreamer.x + self.dreamer.width // 2
centre += self.plant_side * self.dreamer.width * 0.75
self.flowers.spawn(
    x=(centre - self.image("flowers.png").width // 2) % 256,
    y=self.dreamer.y, frame=randrange(4) * 2
)
if not self.moving:
    self.plant_side = -self.plant_side
```

Stopped catches alternate sides until movement resumes.

Notes:
**22:30–23:45.** This checkpoint has one player. Movement resets plant_side every tick. Once stationary, bloom flips it after each catch, so the first follows the last movement and subsequent catches alternate. When we add the second player, the finished source keeps separate plant_side1 and plant_side2 values. Catching plants at the same Y as that player, displaced by 75% of its width. The checkpoint starts without flowers. The 24-slot flower pool recycles the oldest when full, and missed seeds disappear harmlessly beyond the rim. Test catches across the angular seam as well as in the middle of a sprite. The player stays above the flowers because its sprite was created after the flower pool.

Sources: [Allocation and target checks](../../docs/vs2/tutorial/budgets.html), [sample source](examples/dream_garden.py).

---

<!-- .slide: id="tilemap"  data-timing="75" -->

## Fluffy clouds can span several tiles

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=06-tiles" data-checkpoint="06-tiles">Run this checkpoint</a>

<div class="split">
<div>
<pre><code class="language-python" data-trim>self.ground = self.air.tilemap(
    "clouds.png",
    columns=16, rows=22,
    view_width=256,
    view_height=160
)
# A large cloud uses frames 3–8 in a 3×2 block.
self.ground[11, 4] = 3
self.ground[12, 4] = 4
# Reserve seeds after the clouds:
self.seeds = self.air.sprite_pool("seed.png", count=16)</code></pre>
<p>1×1, 2×1 or 3×2 cells. Seeds draw above clouds.</p>
</div>
<img src="assets/tilemaps.png" alt="Muted fluffy clouds in different sizes drift over a dark circular garden, with a pink dreamer at the rim">
</div>

Notes:
**23:45–25:00.** Cloud tiles are frames in another strip, with a separate palette group. One byte per cell chooses a frame or EMPTY_TILE. Dimensions describe the stored grid and its viewport, not a conventional screen resolution. Build places six fluffy cloud shapes in a sparse repeating pattern. Source artwork is packed at 16×16, 32×16 and 48×32 pixels, then cut into adjoining 16-pixel tiles. Medium clouds use two cells; large clouds use a 3×2 block whose frames are placed row by row. There is no padding between the tiles, so the puffs stay continuous across cell boundaries. Transparent cells preserve dark space so seeds remain visible. The map comes first in the middle layer, followed by seeds; flowers and players sit below it. Subdued blue-gray clouds distinguish this flow from the planted garden, while golden seeds remain bright and catchable. A tilemap fits repeated terrain better than dozens of separate sprites, although its rendering cost still depends on the actual viewport and content. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Source: [Tilemaps](../../docs/vs2/tutorial/tilemaps-and-text.html). Image: the actual tilemap checkpoint through the emulator’s WebGL display backend.

---

<!-- .slide: id="scroll"  data-timing="75" -->

## Scrolling moves the view

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=07-scroll" data-checkpoint="07-scroll">Run this checkpoint</a>

```python
pattern_height = 12 * self.ground.tile_height
self.scroll = (self.scroll + 0.45) % pattern_height
self.ground.view_y = self.scroll

for seed in self.seeds:
    seed.y -= self.speed * 0.85
for flower in self.flowers:
    flower.y += 0.45 * 0.85 * 0.08
```

The clouds repeat every twelve tile rows.

Seeds move outward. Flowers drift inward at 8% of normal seed speed.

Notes:
**25:00–26:15.** The map is stored data plus a movable view. Wrapping a twelve-row pattern avoids rewriting cells every tick. Clouds keep scrolling at 0.45 depth units per tick. Seeds decrease Y at 0.3825 normally (85% of cloud speed), or 0.102 while holding A. Only the seeds slow down; clouds and planted flower motion stay steady. Seed sprites are created after the cloud tilemap, so they always paint on top. The stored map has 22 rows: ten for the viewport plus twelve for a complete scroll period, so wrapping cannot expose an empty tail. This ties the visible world's rhythm to the player's choice. A non-repeating world would refill a row when a tile passes. Flower animation uses dream_time, advanced by the constant cloud speed and wrapped to keep it bounded. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Tilemap scrolling](../../docs/vs2/tutorial/tilemaps-and-text.html), [Dream Garden update](examples/dream_garden.py).

---

<!-- .slide: id="mood"  data-timing="75" -->

## The HUD sets the mood

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=08-hud" data-checkpoint="08-hud">Run this checkpoint</a>

```python
self.mood = self.hud.label(
    "steel8x8.png", columns=5, x=108, y=1,
    flip_x=True, flip_y=True, text="RELAX", visible=False
)

# On release, animate y outward until the text clears the rim.
slide_text_out(self.mood, 1, started)
```

Low Y keeps text legible.

Both flips make top text upright.

Notes:
**26:15–27:30.** A label uses a tilemap record rather than a sprite per character. Five eight-column glyphs span forty columns, so x 108 centres the label on top angle 128. At the top, the native inward-facing orientation makes text upside down unless both axes flip. Y 1 keeps it near the rim. RELAX appears while A is held, then slides outward past the rim over 450 ms when released. A new request resets its position and cancels the exit animation. The final game adds a second HUD label for two-second sound feedback. This uses the SDK's existing full CP437 font. A short word also avoids making a large dashboard on a small disc. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Source: [Labels and flips](../../docs/vs2/tutorial/tilemaps-and-text.html), [sample source](examples/dream_garden.py).

---

<!-- .slide: id="scenes"  data-timing="90" -->

## Title, garden and rest scenes

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=09-scenes" data-checkpoint="09-scenes">Run this checkpoint</a>

```python
self.switch(Garden())          # A on the title
self.switch(Rest(flowers))     # B in the garden
self.switch(Garden())          # A after resting

self.push(PauseMenu())         # suspend, show another scene
self.pop()                     # resume below, or leave
```

Transitions commit at the end of the tick.

B keeps the flowers in a still garden.

Notes:
**27:30–29:00.** Rest is a voluntary transition. On B, the game snapshots flower angles, depths and frames at this scene boundary, stops music and switches to Rest. Its build recreates those flowers and a short invitation to begin another dream. There is no game-over scene. Durable state belongs in __init__, while drawable handles belong in build. Use push and pop if you want a modal overlay that resumes the previous scene. Suspension releases its graph and timers, so resumption rebuilds them. Return after queuing a transition. Only one transition is allowed per tick and later callbacks will not touch the outgoing scene. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Scene reference](../../docs/vs2/reference/scene.html), [Title, Garden and Rest source](examples/dream_garden.py).

---

<!-- .slide: id="input"  data-timing="60" -->

## Two people can share one garden

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=10-shared" data-checkpoint="10-shared">Run this checkpoint</a>

```python
joy1.held(LEFT)       # continuous steering
joy2.held(A)          # the friend asks for slower seeds
joy1.just_pressed(B)  # choose the rest scene
```

The second dreamer joins an already reserved sprite.

Y or Back returns to the launcher on either controller.

Notes:
**29:00–30:00.** Both controllers expose stable level and edge reads for the tick. The second player's first steering input or A press reveals the mint dreamer reserved in build. No new sprite allocation is needed. Either active player can hold A to slow the seed flow for both players. Y and Back remain the shared arcade's exit route. Keyboard player two uses Left/Right arrows to steer, numpad 0 for A, numpad 1 for B and numpad 2 for the X action, while two gamepads use their normal mappings. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Controls reference](../../docs/vs2/reference/services.html#vs2-controls), [game controls](examples/dream-garden-guide.html).

---

<!-- .slide: id="audio"  data-timing="60" -->

## A quiet lullaby is optional

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

```python
vs2.audio.music("lullaby", loop=True)
vs2.audio.sound("bloom")
vs2.audio.stop_music()
```

Sound starts on. X toggles music and bloom sounds.

NOISY / QUIET stays for two seconds, then slides past the rim.

MP3s play on the base or desktop host.

Notes:
**30:00–31:00.** The game includes an original soft tone loop and a short bloom chime. Music and bloom sounds start enabled. X stops both, and another X press enables them again. A top-layer NOISY or QUIET notice shows the new state for two seconds, then slides outward past the rim over 450 ms; rapid toggles reset its position and restart that duration. Bloom sound only plays while sound is on. B also stops music before resting. Names resolve to MP3s in this game's sounds folder. Audio does not go into image ROMs or rotor RAM. The ESP32 sends commands to the Raspberry Pi base or emulator host. Music can continue across scenes in the same application and stops when returning to the launcher, so we deliberately stop it sooner at rest. Check the room's volume before the demonstration. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Sources: [Audio API](../../docs/vs2/reference/services.html#vs2-audio), [original audio recipe](examples/artwork.html), [game source](examples/dream_garden.py).

---

<!-- .slide: id="seed-glow" data-timing="90" -->

## Each seed has its own glow rhythm

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

```python
# Each live seed owns [waiting_ticks, glow_tick].
state = self.seed_glows[seed]
if state[0] > 0:
    state[0] -= 1
    seed.frame = 0
else:
    seed.frame = GLOW_FRAMES[state[1] // 6]
    state[1] += 1
```

Wait 90–240 ticks, then pulse through frames 1, 2, 3, 2, 1, 0.

Retiring a seed also removes its glow state.

Notes:
**31:00–32:30.** The first seed checkpoints cycle frames together to demonstrate animation. The finished game replaces that common clock with glow_seed, called once per live seed from move_seeds. A new seed gets [randrange(90, 241), 0]. The excerpt shows its waiting and active phases. Each frame lasts six ticks, so a pulse lasts 36 ticks. At the end, reset the wait to another random 90–240 ticks and the glow tick to zero. Otherwise the next frame lookup would exceed the six-element sequence. retire_seed removes the dictionary entry before returning the sprite to its pool, ensuring a reused slot gets a fresh wait. The wait and animation use game ticks, so holding A slows travel without synchronizing the glows. Flowers use a separate steady paired-frame clock. Seeds sit above clouds in the middle layer, so the small golden pulse stays visible. The final browser checkpoint runs exactly the completed source.

Source: [Finished glow_seed and retire_seed helpers](examples/dream_garden.py).

---

<!-- .slide: id="shared-time"  data-timing="45" -->

## Players can change the pace

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

<div class="split">
<div>
<pre><code class="language-python" data-trim>slow = slow1 or slow2  # either active player
# Arm held-A after releasing the start press.
self.speed = 0.12 if slow else 0.45  # seeds only
self.spawn_ms = 4000 if slow else 1800</code></pre>
<p>Either player can relax the shared seed flow.</p>
</div>
<img src="assets/shared-rest.png" alt="The populated garden with the pink dreamer asleep and RELAX visible at the top">
</div>

Notes:
**32:30–33:15.** The final mechanic is deliberately small. Either player's request slows every seed and lengthens future seed spawn gaps. Clouds and planted flowers retain their normal drift and animation; seeds remain above the clouds. Spawn intervals adapt at the next scheduled callback. Steering stays responsive. Nothing raises the pace because of a score or elapsed time. For the festival, the interesting discussion is what this asks people to do together. They can catch seeds, make room for a friend, hold time slower or simply watch. Invite the audience to imagine another interaction with shared time. Use the Run this checkpoint button to open this stage in the browser; it contains only the features covered so far.

Source: [Garden update](examples/dream_garden.py). Screenshot: an actual held-A game state through the emulator’s WebGL display backend.

---

<!-- .slide: id="budgets"  data-timing="75" -->

## The display graph has explicit budgets

| Resource | Dream Garden | Limit |
|---|---:|---:|
| Layers | 3 | 8 |
| Sprites | 42 | 100 |
| Tilemaps, including labels | 3 | 16 |
| Image strips per asset pack | 5 | 100 |

Read the target limits from `vs2.limits`.

Notes:
**33:15–34:30.** Forty-two sprites means two reserved dreamers, sixteen seeds and twenty-four flowers. Hidden player two and empty pool slots still count. The cloud tilemap, RELAX label and audio notice use three tilemap records. The lower layer draws planted flowers then dreamers; the middle draws clouds then seeds; the HUD paints above both. Five strips include the full font shared by the other scenes. Layers and records are separate resources. VS2 checks the graph at entry and reports the layers contributing to an exceeded budget. Tilemaps can be costly even when their record count is low. Random seed glow uses a small state entry per live seed, removed on retirement. Our bounded garden can run indefinitely without growing its renderer graph. Target timing and heap still need measurement on the console.

Sources: [Resource limits](../../docs/vs2/reference/services.html#vs2-limits), [sample build](examples/dream_garden.py).

---

<!-- .slide: id="hardware-check"  data-timing="90" -->

## The disc decides what is readable

<div class="split">
<div>
<p>Text belongs near the rim.</p>
<p>Dark space keeps the seeds visible.</p>
<p>Check timing and intensity on hardware.</p>
</div>
<img src="assets/budgets-legibility.png" alt="RELAX is readable at radial position 1 near the rim and compressed at radial position 35 toward the centre">
</div>

Notes:
**34:30–36:00.** The emulator preserves renderer semantics, but cannot judge physical brightness or enforce the real output's column deadline. These copies of RELAX use HUD positions 1 and 35. The inner word compresses because angular cells have less circumference. Keep critical instructions near the rim and let the centre convey depth or drifting effects. Our clouds, blossoms and seeds are deliberately sparse. Test their contrast and recognizability on the real LEDs, along with a crowded garden and a sustained session. This is how the display geometry feeds back into the game rather than remaining an introduction slide.

Source: [Hardware and legibility](../../docs/vs2/tutorial/budgets.html). Image: actual font labels through the emulator’s WebGL display backend.

---

<!-- .slide: id="finished-demo"  data-timing="120" -->

## Second checkpoint: a shared dream

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

<div class="split">
<div>
<p><code>./vs-emu.sh --game demos.dream_garden</code></p>
<p>Catch a seed, invite a friend, hold A.</p>
<p>B rests with the flowers. A begins again.</p>
<p class="caption">Desktop demonstration</p>
</div>
<img src="assets/dream-rest.png" alt="The voluntary resting scene keeps the garden's flowers and offers A to begin a new dream">
</div>

Notes:
**36:00–38:00.** Run the finished game. A begins. Start with no flowers. Show the dreamer moving and deliberately catch seeds to grow flowers at the same depth, on the side the player last moved toward. Stop and catch several: the first follows the last movement direction, then plants alternate sides. Move again to reset the sequence. Point out their slow inward drift and the flying seeds’ occasional glow. Let another seed pass to show that it causes no harm. Invite a second person or use Left/Right arrows and numpad 0 to reveal the mint friend. Have either player hold A and point out the RELAX label and slower seeds against steadily moving clouds. The lullaby starts on; use X or keyboard N to toggle it and the bloom sounds. Show the two-second NOISY/QUIET notice. B chooses Rest, preserving the flowers while stopping audio. A begins a fresh dream. M or 1 returns to the launcher. If hardware is available, show the same game without spending the demo on flashing. Otherwise use the screenshots. Keep source open at build, move_seeds and update. The Run this checkpoint button opens the finished game in the browser.

Sources: [Finished source](examples/dream_garden.py), [game instructions](examples/dream-garden-guide.html), [complete download](examples/dream-garden.zip). Screenshot: the actual Rest scene through the emulator’s WebGL display backend.

---


<!-- .slide: id="sharing" data-timing="60" -->

## A game travels with its source and assets

<a class="checkpoint-launch" href="../../emulator/?game=demos.dream_garden&amp;checkpoint=11-audio" data-checkpoint="11-audio">Run this checkpoint</a>

- Matching `code/<name>.py` entry point
- PNG strips and `__images__.yaml`
- Menu icon and VS2 metadata
- Sound files and credits for borrowed assets

[Assets, menu and sharing](../../docs/guides/assets-and-sharing.html)


Notes:
**38:00–39:00.** Share the source folder under games/group/name. Leave generated ROMs to the build pipeline. Keep the entry-point name and metadata consistent, include every referenced image, and check a fresh checkout rather than relying on files left on your laptop. The guide covers menu placement and contributions to the repository. Borrowed artwork and sounds need credits and compatible permissions. A small complete game is a good first contribution. A hardware-tested build lets the next person spend time playing rather than guessing how to assemble the assets. The Run this checkpoint button opens the finished game in the browser.

Source: [Assets, menu and sharing](../../docs/guides/assets-and-sharing.html).

---

<!-- .slide: id="next-game"  data-timing="60" -->

## Your next circular game

[Desktop setup](../../docs/guides/desktop.html)

[Dream Garden source and complete download](examples/dream-garden-guide.html)

[Ventilastation API reference](../../docs/vs2/reference/index.html)

[First-game starter](examples/first_game.py)

[General API walkthrough](../../docs/vs2/tutorial/index.html)

Notes:
**39:00–40:00.** The game guide includes installation, both controller mappings, source and the complete asset folder. The small starter gets one dreamer moving. The general tutorial still teaches the same API using its separate Trench Run example, so do not describe it as a chapter-by-chapter Dream Garden tutorial. The reference gives the full interface after the audience has the circular mental model. Invite people to change a rule, a rhythm or an interaction in this garden, then test that choice on the desktop and physical disc. For a festival audience, ask what shared play on this unusual object could feel like.

Sources: the linked current documentation and sample files.

---

<!-- .slide: id="questions" class="statement" data-timing="300" -->

## Questions

What would you dream on a disc?

[ventilastation.protocultura.net](https://ventilastation.protocultura.net/)

Notes:
**40:00–45:00.** Leave five minutes for questions. Keep the desktop game and source available. Discuss display geometry, shared time, collision space, projection choice, reserve sizing, asset palettes and physical testing. If someone wants to build the console, point them to the repository after the session. The reading view contains these notes and the game download. Finish with a clear route to making a circular game and room for the audience's own ideas.
