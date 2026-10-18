<!-- .slide: id="architecture" data-talk-part="map" data-timing="20" class="cover" data-background-image="../making-games/assets/cover.jpg" data-background-opacity="0.12" -->

<p class="eyebrow">Hardware · software · protocols</p>

# Ventilastation<br>system architecture

<p class="subtitle">Components, execution boundaries and the data between them</p>

Alejandro J. Cura <!-- .element: class="byline" -->

Notes:
**0:00–0:20.**
The question for this talk is where each job runs and exactly what crosses each boundary. Start with the physical console, then follow input and output through its software. Development hosts, native firmware, testing and updates reuse or replace parts of that arrangement. Only the final architectural comparison is chronological. Current-state claims refer to VSDK main at 451941f, October 13, 2026, inspected on October 18. This is an implementation map, not an inventory of firmware installed in every console.

[Sources]
- [SDK source snapshot](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/README.md).
- [Cover photograph](../making-games/assets/cover.jpg).
[/Sources]

---

<!-- .slide: id="deployment-modes" data-talk-part="map" data-timing="50" -->

## One runtime, several deployment modes

<table class="ledger"><thead><tr><th>Mode</th><th>Where game logic runs</th><th>What supplies host services</th></tr></thead><tbody><tr><td>Physical console</td><td>ESP32-S3 rotor</td><td>Raspberry Pi + base Arduino</td></tr><tr><td>Desktop simulation</td><td>Local MicroPython process</td><td>CPython / pyglet host</td></tr><tr><td>Browser simulation</td><td>MicroPython WASM in a worker</td><td>JavaScript UI, WebGL and audio</td></tr><tr><td>Hardware bench</td><td>Real rotor firmware</td><td>Computer + workbench ESP32-S3</td></tr></tbody></table>
<p class="caption">The host supplies input, sound and base outputs; a simulation host also supplies the display.</p>

Notes:
**0:20–1:10.**
Define host carefully. On the physical console it is the Raspberry Pi, which runs the emulator host in no-display console mode. It does not execute the ordinary Python game's rules: those are on the rotor. On a desktop, a separate MicroPython process runs those rules, while the CPython host renders and plays audio. In a browser, the interpreter lives in a worker. The workbench is another physical S3 that stimulates and observes the real rotor. There is also a headless runtime platform for unit tests; it is distinct from the Raspberry Pi's headless host engine. Keep that distinction whenever saying headless.

[Sources]
- [Platform selection](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/__init__.py).
- [Host entry point](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/emu.py).
- [Pi console engine](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/consoleengine.py).
[/Sources]

---

<!-- .slide: id="console-hardware" data-talk-part="hardware" data-timing="80" -->

## The console has three computing boards

<div class="hardware-grid">
<div class="hardware-part"><h3>Stationary base</h3><p><strong>Raspberry Pi</strong><br>Controllers · audio · updates</p><p><strong>Arduino</strong><br>16 RGB LEDs · 2 button lights · servo</p></div>
<div class="hardware-link"><p>Pi ⇄ rotor</p><strong>115200 UART</strong><p>through the slip ring</p><hr><p>Pi → Arduino</p><strong>57600 serial</strong></div>
<div class="hardware-part"><h3>Rotating assembly</h3><p><strong>ESP32-S3</strong><br>Game runtime · native display</p><p><strong>LED strip + Hall sensor</strong><br>Image output · rotation reference</p></div>
</div>
<p class="caption">USB / GPIO controller input enters the Pi. Its audio output feeds the speakers.</p>

Notes:
**1:10–2:30.**
Identify the separate boards and the two separate serial links. The Pi reads controllers and dispatches requests from the rotor. Its link to the rotor is a full-duplex 115200-baud UART transported across the slip ring. The base Arduino receives a second serial stream at 57600; on the deployed Pi the fallback device is the GPIO UART /dev/ttyAMA0, while a registered USB serial adapter is supported on the bench. The Arduino drives the base's lights and needle. The spinning S3 owns the game's state and LED output. A 5 V supply and fan motor are separate hardware subsystems, addressed next. Do not imply a particular controller electrical interface beyond the supported USB/GPIO paths, or an undocumented level-shifter circuit.

[Sources]
- [Physical arrangement](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/input-protocol-v2.md).
- [Serial connections and Arduino baud](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Base Arduino I/O](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/base/vsbase_arduino/vsbase_arduino.ino).
- [Rotor wiring source](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/board_config.py).
[/Sources]

---

<!-- .slide: id="rotation-reference" data-talk-part="hardware" data-timing="65" -->

## Rotation turns time into an angle

<div class="flow"><div class="flow-row"><div class="flow-node"><strong>Motor + arm</strong> <span>Mechanical rotation</span></div><div class="flow-edge"><span>motion</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>Hall sensor</strong> <span>A fixed magnet marks each turn</span></div><div class="flow-edge"><span>GPIO edge</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>S3 display task</strong> <span>Estimate the current column</span></div></div></div>
<p class="clock">600 RPM → 100 ms / turn → <strong>391 µs / column</strong></p>
<p>256 angular columns × 54 radial positions<br><strong>107 physical LEDs:</strong> two opposed arms share the centre.</p>

Notes:
**2:30–3:35.**
The industrial fan motor supplies rotation, not image data. A magnet fixed in the stationary assembly passes the rotor's Hall sensor. The GPIO interrupt records a timestamp; filtering and phase calculation run in task context. The task computes angular column from elapsed time and estimated revolution duration, with a calibration offset. At 600 RPM there are ten revolutions per second. Dividing 100,000 microseconds by 256 gives a 390.625 microsecond angular bin; this is arithmetic, not a newly measured benchmark. Two opposed arms display columns separated by 128. Each has 54 positions but the centre LED is shared: 54 plus 54 minus one equals 107. Game update frequency is independent of these clocks.

[Sources]
- [Geometry constants](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/display_geometry.h).
- [Hall filter, column calculation and centre alias](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c).
- [Mechanical assembly](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/3dmodels/Mechanical%20Assembly.md).
[/Sources]

---

<!-- .slide: id="led-wire-format" data-talk-part="hardware" data-timing="65" -->

## SPI carries complete LED output words

<p class="eyebrow">S3 → LED chain · clock + data · APA102-compatible format</p>

<pre class="packet"><code class="nohighlight">Start frame  |  LED words  |  end / latch clocks
00 00 00 00  |  GB B G R   |  ...
                 ↑
         GB = 0xE0 | brightness[4:0]</code></pre>

<p>Current strip: <strong>NS107S</strong>. Current provisioning default: <strong>30 MHz SPI</strong>.</p>
<p class="caption">The output buffer is 444 bytes per burst. Chip select frames captures for the workbench; the LEDs ignore it.</p>

Notes:
**3:35–4:40.**
Use the wire order rather than an abstract RGB pixel: a LED word is brightness followed by blue, green and red. NS107S strips use the APA102-compatible protocol. The current Makefile provisions 30 MHz by default; older workbench prose describes 20 MHz. This is stored board configuration, not a universal constant for every machine. A 444-byte burst is the driver's transfer-buffer size. Its two arm views intentionally alias the shared centre; the buffer size must not be read as a count of distinct physical LEDs. At 30 MHz, 444 times eight divided by 30 million is about 118.4 microseconds of ideal wire time, before software overhead. The LED protocol itself needs clock and data. The driver adds CS so a workbench SPI slave can identify transaction boundaries.

[Sources]
- [SPI buffers and arm layout](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c).
- [SPI provisioning defaults](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/Makefile).
- [NS107S encoding and colour conversion](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/pov-color-pipeline.md).
- [Workbench CS requirement](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md).
[/Sources]

---

<!-- .slide: id="power-and-calibration" data-talk-part="hardware" data-timing="50" -->

## Power and calibration cross different boundaries

<table class="ledger"><thead><tr><th>Path</th><th>Responsibility</th></tr></thead><tbody><tr><td>External supply → slip ring → rotor</td><td>5 V power; continuous mechanical rotation</td></tr><tr><td>Motor → shaft → LED arm</td><td>Motion; independent of the game command stream</td></tr><tr><td>Game RGB → calibrated encoder</td><td>White balance, radial gain, per-LED gain and brightness</td></tr><tr><td>NVS → both firmware families</td><td>Board wiring, angular alignment and colour profile</td></tr></tbody></table>
<p class="caption"><code>povcal set …</code> changes the active profile; <code>povcal commit</code> persists it.</p>

Notes:
**4:40–5:30.**
The slip ring conducts power as well as the UART signals. The motor is a mechanical subsystem; the game command protocol does not drive its speed in normal operation. On the renderer side, game RGB passes through a calibrated colour pipeline before becoming brightness/PWM words. This compensates for the changing area swept by radial LEDs and the response of the real strip. The profile lives in NVS and is shared with Retro-Go, as are wiring and angular offset. The host can request povcal_state to decode captured LED values consistently. The currently documented profile is PCAL schema 2, 325 bytes; that schema is separate from both the public VS2 API and the scene payload version. Avoid turning board presets into an asserted deployment inventory.

[Sources]
- [Power and slip ring](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/3dmodels/Mechanical%20Assembly.md).
- [Colour profile and calibration commands](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/pov-color-pipeline.md).
- [Shared configuration](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/on-device-design.md).
[/Sources]

---

<!-- .slide: id="software-components" data-talk-part="software" data-timing="70" -->

## Each board has a different software job

<table class="ledger"><thead><tr><th>Computer</th><th>Components</th><th>Primary outputs</th></tr></thead><tbody><tr><td>Raspberry Pi · CPython</td><td>ConsoleEngine → comms dispatcher → audio / base / update services</td><td>Input frames, sound, Arduino commands</td></tr><tr><td>S3 · MicroPython + C</td><td>Launcher → Director → scene → VS2 → native renderer</td><td>LED SPI, host requests, diagnostics</td></tr><tr><td>Base Arduino · C++</td><td>Non-blocking serial parser → local actuator state</td><td>NeoPixels, button lights, servo signal</td></tr></tbody></table>
<p class="caption">The Pi reuses the desktop host with its display disabled. “GPU” names a software task on the S3.</p>

Notes:
**5:30–6:40.**
Give names to the running software rather than only to boards. ConsoleEngine gathers keyboard/gamepad input and services audio without opening a preview window. comms.py receives rotor commands and routes them to audio, the base Arduino, diagnostics and the HTTP update/package server. The rotor's MicroPython entry point configures a platform, loads the launcher and runs Director. A scene handles game state; VS2 exposes display and host services; linked C modules drive the real output. The Arduino parses complete lines and updates local strip, servo and button-light state. It continues blinking and maintaining the legacy show without round trips for every PWM change. These are separate programs with explicit responsibilities, not three parts of one shared Python heap.

[Sources]
- [Pi console engine](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/consoleengine.py).
- [Host command dispatcher](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Rotor entry point](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/main.py).
- [Base firmware](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/base/vsbase_arduino/vsbase_arduino.ino).
[/Sources]

---

<!-- .slide: id="rotor-runtime" data-talk-part="software" data-timing="60" -->

## The rotor runtime selects concrete backends

<div class="stack">
<p><strong>Catalog + app loader</strong> <span>Discover metadata and load the game entry point</span></p>
<p><strong>Director + Scene</strong> <span>Input snapshots, callbacks, scene stack, timers and transitions</span></p>
<p><strong>VS2 + platform interface</strong> <span>Layers, drawables, assets, audio, storage and base services</span></p>
<p><strong>Hardware implementation</strong> <span><code>vshw_vs2</code> · <code>vshw_povdisplay</code> · UART comms</span></p>
</div>

Notes:
**6:40–7:40.**
A game is discovered from its group/name directory and metadata, not by modifying a hard-coded launcher list. The loader imports its entry point. Director owns the running scene stack and polls the selected comms backend; queued control commands and scene transitions pass through this central point. VS2 is the public game model. Its platform interface selects display, sprite/VS2 backend, storage and comms implementations. Hardware imports the vshw C modules and serialcomms. Desktop uses remotepov and emulator sprite records. Browser binds worker calls. Headless tests select no-I/O backends. The runtime model is shared while the implementation of I/O changes. Errors surface through traceback messages to the host.

[Sources]
- [Game discovery](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/catalog.py).
- [App loader](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/app_loader.py).
- [Director](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py).
- [Hardware backends](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/hardware.py).
[/Sources]

---

<!-- .slide: id="render-concurrency" data-talk-part="software" data-timing="80" -->

## Rendering and LED service have separate budgets

<div class="two-columns">
<div><h3>Core 1 · game runtime</h3><p>MicroPython callbacks, input and scene state</p><p>Normal Director loop targets <strong>30 ms</strong>.</p></div>
<div><h3>Core 0 · C display task</h3><p>Hall phase → serve front-buffer columns → SPI</p><p>Project into the back buffer when deadline slack permits.</p></div>
</div>
<p class="claim">Complete polar image → publish buffer → next LED columns</p>
<p class="caption">Two 256 × 54 × 4-byte buffers occupy 110,592 bytes of internal SRAM.</p>

Notes:
**7:40–9:00.**
Separate three things: the game tick, projection of scene state into a polar image, and time-critical servicing of the LED bus. Current coreTask on core 0 performs column service and projects additional columns into the back buffer when there is slack. VS2 projection cooperatively calls service during heavier work. A complete ring makes the new buffer visible. MicroPython runs on core 1 and updates native scene records. Two internal-SRAM buffers are each 55,296 bytes, so together require 110,592 bytes, excluding DMA and other state. This is not a full snapshot transaction over all Python game state. A stale comment mentions projection on a core-1 task; follow the actual loop and the single-task correction. Original Super Ventilagon retains its own C loop path.

[Sources]
- [Actual scheduler and buffers](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c).
- [Core assignment](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/minispi.h).
- [Director tick](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py).
- [Single-task renderer correction](https://github.com/ventilastation/vsdk/commit/8946100).
[/Sources]

---

<!-- .slide: id="input-protocol" data-talk-part="protocols" data-timing="105" -->

## Input v2 multiplexes state and commands

<p class="eyebrow">Host → rotor · same framing over UART, TCP or Windows pipe</p>

<pre class="packet"><code class="nohighlight">Joystick state:  2A  joy1  joy2  extra      (4 bytes)
Example:         2A   12    00    00       (P1 Right + A)
Control action:  exit\n                   (ASCII line)</code></pre>

<table class="ledger"><thead><tr><th>Fields</th><th>Meaning</th></tr></thead><tbody><tr><td>joy1 / joy2 · 7 bits</td><td>Left, Right, Up, Down, A, B, C/X</td></tr><tr><td>extra · 7 bits</td><td>P1/P2 Y, Start, Back; one reserved bit</td></tr><tr><td>Receiver semantics</td><td>Latest complete joystick snapshot; queued commands</td></tr></tbody></table>
<p class="caption">RESYNC: <code>0A 0A D2 45 53 59 4E 43 0A</code> → device reset / identification.</p>

Notes:
**9:00–10:45.**
Walk one actual four-byte packet. 0x2A is the marker. 0x12 is right bit 1 plus A bit 4. The other two state fields are zero. The parser reads exactly three bytes after the marker, so byte values that happen to equal printable characters or another asterisk are still data at those positions. Bit 7 is clear in state bytes; this reserves high-bit markers for control such as RESYNC and workbench-local commands. The receiver replaces joystick state; it does not queue every state update. Discrete ASCII command lines are queued and Director consumes one per tick. Commands have a 256-byte accumulation cap. Host engines can send at their input loop rate or only on state change; do not assert a universal 30-packets-per-second wire rate. RESYNC is a fixed nine-byte sequence recognized independently of parser state. It restarts or reinitializes the addressed device and returns VENTILASTATION plus kind/version/hash. The workbench intercepts its own RESYNC rather than forwarding it.

[Sources]
- [Input protocol](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/input-protocol-v2.md).
- [Actual parser](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/input_parser.py).
- [Input sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Console change-based sending](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/consoleengine.py).
[/Sources]

---

<!-- .slide: id="host-protocol" data-talk-part="protocols" data-timing="75" -->

## Rotor requests use lines and sized binary payloads

<p class="eyebrow">Runtime → host · full-duplex return direction</p>

<pre class="packet"><code class="nohighlight">sound &lt;group&gt;.&lt;game&gt;/&lt;clip&gt;\n
base servo 128\n
traceback &lt;N&gt;\n   [exactly N bytes]
vs2_scene &lt;N&gt;\n   [exactly N bytes; simulation]</code></pre>

<p>The command determines the payload size. A binary payload may contain newline bytes.</p>
<p class="caption">Live hardware sends audio, controls and diagnostics here. Its graphics go directly to LED SPI.</p>

Notes:
**10:45–12:00.**
This is a different framing rule from joystick input. A command line is terminated by newline, then a handler reads the exact declared or fixed binary length. For example, traceback has a byte count, palette count implies blocks of 1024 bytes, and the legacy sprites command has a fixed 500-byte table. It is not a generic JSON RPC or a universal length-prefixed envelope, and the stream does not provide a universal checksum or sequence number. The parser must keep framing in step. The dispatcher implements sound/music, base controls, calibration and profiler state, OTA/package progress and diagnostics. In software simulation, display assets and scene packets use the same host abstraction. On a real rotor, a vs2_scene image does not travel over the slow base UART; native output drives the LEDs.

[Sources]
- [Host framing and commands](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/host-protocol.md).
- [Host receiver](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Serial sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/serialcomms.py).
- [Simulation display sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/remotepov.py).
[/Sources]

---

<!-- .slide: id="one-frame-sequence" data-talk-part="protocols" data-timing="75" -->

## Follow one input through the live console

<ol class="trace">
<li><strong>Pi input</strong> <span>Encode <code>* joy1 joy2 extra</code> → UART → slip ring</span></li>
<li><strong>Rotor Director</strong> <span>Read latest input → scene <code>update()</code> → VS2 state</span></li>
<li><strong>C display task</strong> <span>Project back buffer → publish → Hall-timed SPI columns</span></li>
<li><strong>Host request</strong> <span><code>sound …\n</code> → UART back to Pi → local audio asset</span></li>
</ol>
<p class="caption">The image path remains on the rotor. Sound and physical base feedback leave it.</p>

Notes:
**12:00–13:15.**
Use this trace to reconnect the component diagrams to execution. A controller change is observed by the host and encoded into state. The rotor parser records it. At a Director tick the game sees the snapshot, changes positions, handles collisions and can request sound or base feedback. On hardware, VS2 writes native render state through its linked C backend. The display task constructs and publishes completed output while observing the physical-column deadline. In parallel the scene's audio request travels back through UART to the dispatcher, which queues playback using a local clip. The Pi is not rendering the game to a stream for the rotor, and the rotor is not storing or synthesizing ordinary game audio. The branches have different time budgets; this sequence is not a single synchronous transaction.

[Sources]
- [Director tick and services](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py).
- [VS2 services](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/vs2/__init__.py).
- [Hardware bindings](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/hardware.py).
- [Output scheduler](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/povdisplay/povdisplay.c).
- [Audio dispatch](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
[/Sources]

---

<!-- .slide: id="base-actuator-protocol" data-talk-part="protocols" data-timing="55" -->

## The Pi relays actuator intent to the Arduino

<div class="flow"><div class="flow-row"><div class="flow-node"><strong>Rotor app</strong> <span>VS2 / native base service</span></div><div class="flow-edge"><span>115200 UART</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>Pi dispatcher</strong> <span>Validate and canonicalize</span></div><div class="flow-edge"><span>57600 serial</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>Base Arduino</strong> <span>Local actuator state</span></div></div></div>
<pre class="packet"><code class="nohighlight">base leds 255 0 0\n
base servo 128\n
base buttons 3 250\n</code></pre>
<p class="caption">Servo position is 0–255. The Arduino owns degree limits, gamma and blink timing.</p>

Notes:
**13:15–14:10.**
The host validates base commands and forwards their canonical form to the dedicated base Arduino. Values are normalized: servo 128 is a point in the byte range, not 128 degrees or a PWM duty cycle. Only Arduino firmware knows the current physical endpoints, 106 degrees at rest and 13 at full travel. base buttons has a two-bit mask and a full blink period; zero means steady. Base LEDs are decimal RGB channel bytes and the Arduino applies its own gamma table. Existing Super Ventilagon still sends legacy arduino commands that the host translates to ventilagon start/stop/reset/attract lines. Those start a self-contained timed show on the Arduino. The compatibility path shares the servo/button state but preserves its legacy strip colours.

[Sources]
- [Base control contract](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/base-control-api.md).
- [Arduino sender/relay](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Arduino command handlers](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/base/vsbase_arduino/vsbase_arduino.ino).
[/Sources]

---

<!-- .slide: id="audio-protocols" data-talk-part="protocols" data-timing="75" -->

## Audio has two host-side execution paths

<table class="ledger"><thead><tr><th>Game type</th><th>Rotor sends</th><th>Host does</th></tr></thead><tbody><tr><td>Python games / Voom</td><td>Named <code>sound</code>, <code>music</code> or <code>notes</code> requests</td><td>Play local MP3 / converted assets</td></tr><tr><td>Console emulators</td><td><code>achip</code> → <code>aframe N nsamples</code> + register log → <code>astop</code></td><td>Replay chip writes; synthesize and buffer PCM</td></tr></tbody></table>
<p class="clock">115200 8N1 ≈ <strong>11.5 KB/s</strong></p>
<p class="caption">32 kHz × 16-bit × stereo PCM needs 128 KB/s. Register logs fit the smaller transport budget.</p>

Notes:
**14:10–15:25.**
The asset path is the established service: clips reside in the host's game sounds directory or package cache. Voom converts its named sound and music assets for the same mechanism. Native console emulation is different because sound is driven by emulated chip writes. The rotor bridge logs writes with compact timing information per video frame. achip establishes the system, aframe supplies length and sample count followed by binary events, amap can add mapper/sample-related state, and astop tears it down. Desktop hosts load chip libraries through ctypes and feed a PCM ring buffer to playback. Remote browser mode uses WASM synthesizers and an AudioWorklet. These chip logs are distinct from WebRTC video and from a PCM stream sent by the rotor. The audio status document still calls for real-hardware listening validation; implementation does not establish that every console/core is proven in operation.

[Sources]
- [Audio bridge status and wire format](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/emulator-audio.md).
- [Audio dispatcher](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Desktop synthesis](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/emu_audio.py).
- [Browser chip host](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/web/chip-audio-host.js).
[/Sources]

---

<!-- .slide: id="assets-and-memory" data-talk-part="software" data-timing="60" -->

## Graphics and sounds have different storage paths

<table class="ledger"><thead><tr><th>Artifact</th><th>Format and destination</th></tr></thead><tbody><tr><td>PNG + image manifest</td><td>Builder → indexed strips, palettes and glyph maps</td></tr><tr><td>Sprite ROM</td><td>Strip/palette offset tables; one-byte palette indices</td></tr><tr><td>Rotor ROMZ</td><td>Uncompressed-size prefix + gzip → preallocated RAM buffer</td></tr><tr><td>Sounds</td><td>Host files / package cache; omitted from rotor filesystem</td></tr></tbody></table>
<p class="caption">Strip header: width − 1, height, frames − 1, palette. Index <code>0xFF</code> is transparent.</p>

Notes:
**15:25–16:25.**
The shared sprite container is a platform boundary. Python/Pillow and browser/Node builders produce the same layout. A header indexes strips and palette blocks; each strip has a name, four-byte geometry/palette header, column-major image data and a glyph mapping trailer. Width and frame count are stored minus one so a full 256-column image or 256-frame font fits in a byte. The director normalizes older encodings when loading. On flash the ROMZ wrapper stores an uncompressed size before gzip, letting the board inflate directly into one preallocated buffer rather than repeatedly growing it. Palettes and strips remain in memory while rendering. This graphics ROM is separate from retro console ROMs. Ordinary sound files are excluded from the rotor filesystem image and are resolved by the host.

[Sources]
- [Normative ROM layout](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/rom-format.md).
- [Rotor filesystem packaging](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/build_micropython_fs.py).
- [Director asset loader](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py).
[/Sources]

---

<!-- .slide: id="native-boot" data-talk-part="software" data-timing="80" -->

## Native apps switch execution ownership at reboot

<table class="ledger"><thead><tr><th>Flash region · 16 MB target</th><th>Role</th></tr></thead><tbody><tr><td>micropython</td><td>Normal launcher, Python games, linked Ventilagon C module</td></tr><tr><td>prboom-go / retro-core / fmsx</td><td>Voom and native console firmware images</td></tr><tr><td>LittleFS · vfs</td><td>Shared code, graphics, game ROMs and user data</td></tr><tr><td>NVS</td><td>Board wiring, calibration and selected native app / ROM</td></tr><tr><td>factory</td><td>Permanent MicroPython recovery environment</td></tr></tbody></table>
<p class="caption">Select → write launch state → set boot partition → reboot. Native exit targets normal MicroPython.</p>

Notes:
**16:25–17:45.**
There are two distinct native integration strategies. Original Super Ventilagon is C linked into the MicroPython firmware; a Python scene enters and exits it. Heavy Retro-Go apps use dedicated flash partitions. The launcher writes the selected app, emulator system and ROM path, then the vshw_native_apps hook selects a boot partition and restarts. The native app owns its framebuffer and POV driver. It sets the next boot target back to normal MicroPython, so exiting or resetting restores the Python launcher and selection. NVS shares wiring and calibration across firmware families. The shared vfs is LittleFS despite its historical partition subtype label. Factory is a permanent recovery copy, separate from normal micropython. The native-app plan's future same-image takeover is not the current implementation.

[Sources]
- [Actual partition table](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/partitions-ventilastation.csv).
- [NVS and native launch](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/on-device-design.md).
- [Native C launch hook](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/rotor/modules/native_apps/native_apps.c).
- [Original game adapter](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/ventilagon/README.md).
[/Sources]

---

<!-- .slide: id="desktop-transports" data-talk-part="development" data-timing="65" -->

## Desktop simulation crosses a process boundary

<div class="flow"><div class="flow-row"><div class="flow-node"><strong>MicroPython process</strong> <span>Game + Director + remotepov</span></div><div class="flow-edge"><span>TCP :5005 / Windows pipe</span><b aria-hidden="true">⇄</b></div><div class="flow-node"><strong>CPython host</strong> <span>comms dispatcher + native renderer</span></div><div class="flow-edge"><span>local calls</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>Window + speakers</strong> <span>Polar preview + host audio</span></div></div></div>
<p class="packet-line"><strong>Host → runtime:</strong> input v2 + control lines</p>
<p class="packet-line"><strong>Runtime → host:</strong> image strips, palettes, scene payloads + service commands</p>
<p class="caption">The CPython host connects to the MicroPython TCP server. Windows uses <code>ventilastation-emu</code>.</p>

Notes:
**17:45–18:50.**
On non-Windows desktop systems, the MicroPython comms backend listens on TCP port 5005 and the CPython host connects. The misleading variable name UDP_THIS in that module does not make it a UDP server: it creates SOCK_STREAM. Windows uses a duplex named pipe. Input and host command formats are reused, with graphics added because the host now supplies the display. remotepov sends assets when registered and resends palettes/strips after reconnection. A normal VS2 frame sends one vs2_scene packet rather than both V1 and V2 state. The desktop renderer reuses the actual C compositor for scene/strip parity and presents the polar result. A host receive thread and a UI/playback thread exchange published state; they are separate from the interpreter process.

[Sources]
- [Desktop platform](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/desktop.py).
- [TCP server](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/comms.py).
- [Host connections](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/comms.py).
- [Display sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/remotepov.py).
- [Host renderer](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/povrender.py).
[/Sources]

---

<!-- .slide: id="scene-payload" data-talk-part="protocols" data-timing="65" -->

## VS2 exports a versioned scene description

<p class="eyebrow">Public API revision 2 · scene wire payload version 3</p>

<pre class="packet"><code class="nohighlight">16-byte header: "VS2\0", version, counts, record sizes
8-byte layer records
24-byte sprite records
32-byte tilemap records + cell data
2-byte draw references in paint order</code></pre>

<p>Scenes own layers; layers own projections and drawables.</p>
<p class="caption"><code>build()</code> seals the display graph. <code>update()</code> changes state and reuses reserved pools.</p>

Notes:
**18:50–19:55.**
The current encoder explicitly uses PAYLOAD_VERSION 3. The host protocol document retains a table of the first payload version, which does not cover today's tilemaps and ordered drawable references. Use the current encoder and decoder for exact behavior. The 16-byte little-endian header stores magic, wire version, layer/sprite/tilemap counts and record sizes. It is followed by records, tile cells and ordered two-byte references that preserve mixed sprite/tilemap painting. Positions use signed fixed-point coordinates. This is a scene description, not a full RGB frame, and asset strips/palettes are supplied separately. The public VS2 API owns layers and render resources, seals structural creation after build, and reserves capacity through pools. That restriction does not prohibit arbitrary Python allocations or guarantee a zero-GC game tick. The hardware C backend can consume native state without serializing this payload onto UART.

[Sources]
- [Current scene encoder and constants](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/vs2/__init__.py).
- [Versioned scene decoder](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/povrender.py).
- [Accepted scene ownership decisions](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-decisions.md).
[/Sources]

---

<!-- .slide: id="browser-transport" data-talk-part="development" data-timing="75" -->

## Browser simulation uses a worker bridge

<div class="flow"><div class="flow-row"><div class="flow-node"><strong>UI thread</strong> <span>Editor · Gamepad API<br>WebGL · audio</span></div><div class="flow-edge"><span>postMessage</span><b aria-hidden="true">⇄</b></div><div class="flow-node"><strong>Worker host</strong> <span>RPC + frame / command events</span></div><div class="flow-edge"><span>__vs_host calls</span><b aria-hidden="true">⇄</b></div><div class="flow-node"><strong>MicroPython WASM</strong> <span>Director · scenes<br>browser platform</span></div></div></div>
<pre class="packet"><code class="nohighlight">post_present_ptr(sprite_ptr, sprite_len, frame_ptr, frame_len)
post_command_ptr(line_ptr, line_len, data_ptr, data_len)</code></pre>
<p class="caption">Pointer + length crosses the MicroPython ↔ JS boundary; worker events still copy / transfer data to the UI.</p>

Notes:
**19:55–21:10.**
The UI thread runs editing, controller polling, rendering and audio. The bridge creates a module worker. That worker loads MicroPython WebAssembly, mounts runtime-bundle files and registers the __vs_host interface. MicroPython pulls joy1, joy2 and extra as primitive values; the semantic state matches input v2 without requiring a literal four-byte UART packet in this in-memory path. For output, pointer-and-length calls let the worker read existing WASM memory. It reconstructs frame/command events and sends them to the UI. Passing fresh Python bytes objects through object bridging previously retained heap; the pointer path addresses that boundary. It is not end-to-end zero-copy. WebGL composes the display with a fallback renderer where necessary. Browser storage and editor workspaces are additional host concerns, while the game model remains shared.

[Sources]
- [Browser implementation](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/platforms/browser.py).
- [Worker](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/web/wasm-worker.js).
- [UI-to-worker bridge](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/web/micropython-bridge.js).
- [Browser architecture](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/web-emulator-architecture.md).
[/Sources]

---

<!-- .slide: id="workbench-hardware" data-talk-part="testing" data-timing="80" -->

## The workbench exercises real electrical interfaces

<table class="ledger"><thead><tr><th>Workbench ESP32-S3 connection</th><th>Interaction with the real rotor</th></tr></thead><tbody><tr><td>Hall output + reset EN</td><td>Generate 0–700 RPM pulses; reset the board</td></tr><tr><td>SPI CLK / data / CS inputs</td><td>Passively capture the rotor’s LED transactions</td></tr><tr><td>UART ⇄ USB-Serial-JTAG</td><td>Bridge input, audio and system commands</td></tr><tr><td>Wi-Fi station + mDNS</td><td>Stream LED telemetry; accept RPM / reset controls</td></tr></tbody></table>
<p class="caption">The rotor runs normal firmware. Real LED output is observed without a moving arm.</p>

Notes:
**21:10–22:30.**
The extra S3 is both stimulus and observation. It generates a Hall-like negative pulse and drives reset low then releases it. It listens on clock, data and chip select as a SPI slave; it never drives the LED bus. CS is needed by the capture peripheral even though the LEDs ignore it. The UART bridge sends the exact ordinary controller/command traffic toward the DUT and returns host requests to the computer's USB serial connection. The workbench joins the existing network and advertises ventilastation-workbench.local. The two channels are deliberate: serial input/audio stays independent of the high-volume Wi-Fi image preview. Automated USB capture is another path on the same bridge. The board under test cannot establish the mechanical properties of the assembled fan.

[Sources]
- [Workbench wiring and sequence](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md).
- [SPI capture](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/workbench/workbench_esp32s3/main/led_capture.c).
- [USB / UART bridge](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/workbench/workbench_esp32s3/main/serial_bridge.c).
[/Sources]

---

<!-- .slide: id="workbench-protocols" data-talk-part="protocols" data-timing="110" -->

## Workbench exposes two capture formats

<p class="eyebrow">Wi-Fi UDP :5005 · live preview</p>
<pre class="packet"><code class="nohighlight">A1 | frame_seq:u32 LE | chunk:u8 | 864 payload bytes
 6-byte header + 4 columns × 54 LEDs × 4 bytes = 870 bytes
 64 chunks describe a 55,296-byte polar LED capture</code></pre>

<p class="eyebrow">USB serial · on-demand acceptance capture</p>
<pre class="packet"><code class="nohighlight">Host: D3 + "capture\n"
Board: "wb_frame 55296 &lt;crc32&gt;\n" + 55,296 bytes</code></pre>
<p class="caption">UDP control: <code>hello\n</code>, <code>rpm 600\n</code>, <code>reset\n</code>. The freshest sender is the preview client.</p>

Notes:
**22:30–24:20.**
Explain why there are two designs. UDP preview sends a six-byte header: 0xA1, a little-endian uint32 snapshot sequence and an 8-bit chunk index. Four columns times 54 cells times four raw APA102 bytes gives 864 payload bytes; total 870 fits the intended LAN MTU. A preview client keeps the most recent sequence per chunk. Missing chunks retain previous pixels; old/reordered chunks do not replace fresher data. Snapshot sequence is not a revolution counter. hello keeps the subscription alive; the last sender owns the subscription and it times out after five seconds. This local protocol has no authentication or retransmission. Repeatable acceptance uses the serial escape 0xD3 plus a local command. capture returns one locked 55,296-byte frame with CRC32; normal forwarding/logging pauses during it. The host validates CRC before comparison. RESYNC 0xD2 is a separate control marker. Static parity is tested at 400 RPM; timing/stability gates run at 600 and 700. Neither mechanism is the TCP host command called frame_rgb.

[Sources]
- [UDP header and client policy](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/workbench.md).
- [Actual UDP sender](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/hardware/workbench/workbench_esp32s3/main/telemetry.c).
- [USB capture framing](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/vs2-hardware-acceptance.md).
- [Host telemetry reassembly](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/workbench_telemetry.py).
[/Sources]

---

<!-- .slide: id="remote-workbench" data-talk-part="development" data-timing="60" -->

## Remote access adds a gateway around the bench

<table class="ledger"><thead><tr><th>Connection</th><th>Traffic</th></tr></thead><tbody><tr><td>Browser ⇄ HTTPS / WSS gateway</td><td>Login, one-use ticket, control lease, input, audio events, signaling</td></tr><tr><td>Gateway ⇄ workbench</td><td>USB serial for host commands; UDP :5005 for LED captures</td></tr><tr><td>Gateway ⇄ browser WebRTC</td><td>H.264 video over DTLS-SRTP; ICE direct path or TURN relay</td></tr><tr><td>VPS ⇄ local gateway</td><td>Authenticated FRP tunnel → 127.0.0.1:8765</td></tr></tbody></table>
<p class="caption">Captured frames become video. Chip-audio events remain a separate stream synthesized in the browser.</p>

Notes:
**24:20–25:20.**
Remote mode is not the local WASM simulator executing the game. The physical rotor runs it, and the gateway mediates access to its workbench. A VPS terminates HTTPS/Google login and the FRP tunnel exposes the loopback gateway. The browser obtains a one-use WebSocket ticket and an exclusive control lease before driving input. Control, audio events and WebRTC signaling use the authenticated channel. The gateway receives LED captures through UDP and sends H.264 video as a WebRTC track; when a direct ICE pair works, media bypasses the VPS tunnel. TURN is a separate fallback relay. The browser can synthesize native chip audio from aframe events instead of receiving gateway-generated PCM. Captures are a display reconstruction, not a camera view of the fan. The architecture is implemented in the inspected source; do not claim a fresh remote smoke test was run for this presentation.

[Sources]
- [Remote topology and media](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/remote-workbench-access.md).
- [Gateway access and wire handlers](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/remote_gateway.py).
- [Browser chip-audio path](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/emulator-audio.md).
[/Sources]

---

<!-- .slide: id="ota-control-data" data-talk-part="maintenance" data-timing="100" -->

## Updates separate the trigger from the bulk transfer

<div class="flow"><div class="flow-row"><div class="flow-node"><strong>Host command</strong> <span>ota_start URL</span></div><div class="flow-edge"><span>UART</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>Rotor reboot</strong> <span>Persist update intent<br>Run before normal renderer</span></div><div class="flow-edge"><span>Wi-Fi → :5653</span><b aria-hidden="true">→</b></div><div class="flow-node"><strong>HTTP client</strong> <span>GET /manifest<br>Download changed files / images</span></div></div></div>
<ol>
<li><strong>Tier 1:</strong> LittleFS files</li>
<li><strong>Tier 2:</strong> native firmware partitions</li>
<li><strong>Tier 3:</strong> MicroPython through factory recovery</li>
</ol>
<p class="caption">Default source: <code>http://ventilastation-base.local:5653</code>. Hashes verify content and skip unchanged files.</p>

Notes:
**25:20–27:00.**
The host sends a short control line over the existing serial stream. Director writes /ota_request and resets. Early boot sees the request and starts the frozen updater before the ordinary VS2/game rendering pipeline. It connects Wi-Fi, resolves the advertised base name, fetches the manifest over HTTP and applies three update tiers. This is a pull from the rotor, not a bulk firmware stream pushed over 115200 UART. Tier 1 synchronizes files; tier 2 streams native app partitions; tier 3 replaces normal MicroPython by handing off through the permanent factory environment when necessary. The normal image cannot overwrite itself while executing. Hashes allow incremental transfer and content checks; local HTTP and SHA256 do not imply an authenticated or signed firmware channel. New normal firmware confirms a successful boot after real Director ticks, otherwise rollback can return to factory. Wi-Fi bulk transfer is isolated from the normal renderer because concurrent operation was problematic. OTA reports return through ota_progress/done/error lines, while a separate minimal local renderer displays progress rings.

[Sources]
- [Current OTA state machine](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/ota.md).
- [Boot-time request dispatch](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/main.py).
- [Host HTTP service](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/upgrade_server.py).
- [Director control dispatch](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/director.py).
[/Sources]

---

<!-- .slide: id="game-package-flow" data-talk-part="maintenance" data-timing="55" -->

## A game package splits at the base

<table class="ledger"><thead><tr><th>Step</th><th>Transfer</th></tr></thead><tbody><tr><td>Editor / CLI → base</td><td>HTTP POST a <code>.vs2</code> ZIP with code, ROMs, metadata and sounds</td></tr><tr><td>Base → rotor command</td><td><code>install_start &lt;url&gt; &lt;sha256&gt; &lt;size&gt;</code></td></tr><tr><td>Rotor → HTTP server</td><td>Reboot; fetch <code>.no-sound.vs2</code>, verify and stage install</td></tr><tr><td>After install</td><td>Merge menu icon; reboot launcher. Audio stays in the base package.</td></tr></tbody></table>
<p class="caption">Same local HTTP service, port 5653. Package flow is implemented; the documented hardware checklist remains pending.</p>

Notes:
**27:00–27:55.**
One-game installation is distinct from a full system OTA. The package includes code, compiled graphics and sounds. The base stores it, exposes audio through its cache, and derives a stripped package for the rotor. POSTing install sends a short UART instruction containing URL, hash and size. Early boot runs the installer, downloads the one stripped ZIP, verifies it and stages the game directory. Its menu icon is merged into the launcher ROM. System OTA and installed packages have different ownership rules; a full authoritative USB filesystem reflash can wipe local additions. The editor should use the local server origin for POSTs; a hosted HTTPS editor cannot assume it can POST to plain HTTP on the LAN. As with audio, the package document explicitly leaves a real-board checklist unrun, so describe code and format rather than claiming operational acceptance.

[Sources]
- [Package format, endpoints and validation status](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/game-packages.md).
- [Package manager](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/emulator/package_manager.py).
- [Board installer](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/apps/micropython/ventilastation/installer.py).
[/Sources]

---

<!-- .slide: id="architecture-evolution" data-talk-part="history" data-timing="90" -->

## The boundaries evolved more than the shape

<table class="ledger"><thead><tr><th>Generation</th><th>Execution and link architecture</th></tr></thead><tbody><tr><td>2012–2013 origin</td><td>POV idea and seven-LED experiment</td></tr><tr><td>2015 · Super Ventilagon</td><td>Nano C++ game + TLC5940 LEDs; Wixel serial / rotating battery; Pi base</td></tr><tr><td>2018–2019 · Ventilastation</td><td>ESP32: MicroPython game + C renderer; desktop host over TCP</td></tr><tr><td>2024–2025 · VSDK / S3</td><td>Upstream MicroPython + user C modules; slip-ring assembly documented</td></tr><tr><td>2026 · current interfaces</td><td>VS2, WASM host, native app partitions, workbench capture and HTTP updates</td></tr></tbody></table>
<p class="caption">Rotor/base ownership persists. Display, host, storage and maintenance interfaces become explicit.</p>

Notes:
**27:55–29:25.**
Keep this to architectural deltas. The older history talk places the inspiration in 2012 and seven-LED PyCamp experiment in 2013; a working 2012 prototype is not established. In 2015 a specialised C++ game on a Nano drives TLC5940 LEDs, with a rotating battery and Wixel radio carrying serial to a Pi. The first project-specific ESP32 commit is November 2018, within a LoBo MicroPython fork. Python game logic and C rendering are separated, and the 2019 desktop emulator makes the host replaceable. VSDK imports the code in August 2024, ports C modules to upstream MicroPython and records S3 working in October. Slip-ring assembly documentation exists by April 2025; its adoption date is still an author question. The 2026 additions expose new boundaries: a WASM bridge, sealed scene model, separately booted native apps, captured electrical output and HTTP maintenance. No jam gallery or personal biography is needed to explain those changes.

[Sources]
- [Earlier hardware/history talk](../../dump2024/).
- [2015 game sources](https://github.com/clubdejaqueo/super-ventilagon/tree/f4040113e562af43333f63e0271c6e80e2c610c0).
- [First project-specific ESP32 commit](https://github.com/alecu/ventilastation/commit/9435a21ca5d2fa00211896c9ca45e2f50d53172d).
- [VSDK import](https://github.com/ventilastation/vsdk/commit/6b799b9).
- [Upstream MicroPython modules](https://github.com/ventilastation/vsdk/commit/7206324).
- [Slip-ring documentation](https://github.com/ventilastation/vsdk/commit/8842bc9).
[/Sources]

---

<!-- .slide: id="interface-summary" data-talk-part="closing" data-timing="35" -->

## Trace the owner, the transport and the payload

<p class="closing"><strong>Rotor:</strong> game state and timed light output<br><strong>Host:</strong> input, sound and base services<br><strong>Workbench:</strong> stimulus and captured output</p>

<p>UART commands · SPI LED words · scene payloads<br>Worker events · UDP captures · HTTP updates</p>

<p class="closing-links"><a href="protocol-reference.html">Protocol reference</a><a href="sources.html">Code and sources</a><a href="../../docs/internals/README.html">SDK internals</a></p>

Notes:
**29:25–30:00.**
Finish by returning to the deployment map. For any feature ask which process owns the state, which transport crosses the boundary, and how its payload is framed. Those three answers distinguish physical operation from simulation, capture from display state, and a maintenance trigger from a firmware download. The protocol reference collects packet fields, ports and the relevant source files so people can inspect exact implementations after the talk. Questions follow the timed thirty minutes.

[Sources]
- [SDK internals index](https://github.com/ventilastation/vsdk/blob/451941fa66341ec22f09aa39fb5147b58b3e83fa/docs/internals/README.md).
- [Detailed protocol reference](protocol-reference.html).
[/Sources]
