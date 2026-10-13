#!/usr/bin/env python3
"""Export real SDK scenes and packed assets for the WebGL slide captures.

No image drawing happens here. capture-presentation.mjs renders these payloads
with the SDK's WebGL scene compositor and LED display backend.
"""
import argparse
import base64
import importlib.util
import json
import os
import random
import sys
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--sdk', type=Path, required=True)
parser.add_argument('--out', type=Path, required=True)
options = parser.parse_args()
SDK = options.sdk.resolve()
options.out = options.out.resolve()
os.chdir(SDK)
sys.path[:0] = [str(SDK / 'tests'), str(SDK)]
import test_dream_garden as fixture
import vs2
from ventilastation import api_guard
from ventilastation.app_loader import load_app
from ventilastation.director import configure_runtime, director, reset_runtime

frames = []


def step(one=0, two=0, count=1):
    for _ in range(count):
        comms = director.platform.comms
        comms.next_joy2 = lambda: two
        comms.next_extra = lambda: 0
        comms.push_input(bytes([one]))
        director.step_once()


def start(checkpoint=None):
    reset_runtime()
    api_guard.reset()
    random.seed(2026)
    runtime = configure_runtime('headless')
    load_rom = runtime.load_rom
    runtime.load_rom = lambda name: load_rom(str(SDK / 'apps/micropython' / name))
    load_app('demos.dream_garden')
    if checkpoint:
        file = SDK / 'games/demos/dream_garden/code/checkpoints' / (checkpoint + '.py')
        spec = importlib.util.spec_from_file_location('capture_checkpoint', file)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        director.scene_stack[-1].switch(module.main())
        step()
    else:
        step(fixture.A)
        step()
    scene = director.scene_stack[-1]
    scene.pending_calls.clear()
    return scene


def capture(scene, name, description):
    runtime = director
    encode = lambda data: base64.b64encode(data).decode('ascii')
    frames.append(dict(name=name, description=description,
                       scene=encode(vs2.export_scene_payload(scene)),
                       palette=encode(runtime.palette_data),
                       strips=[dict(slot=slot, data=encode(data))
                               for slot, data in runtime._stripe_buffers.items()]))


garden = start()
capture(garden, 'garden-start.png', 'Finished game starts with no planted flowers.')
step(0, fixture.LEFT)
for index in range(12):
    player = garden.dreamer if index % 2 == 0 else garden.friend
    player.x = (index * 21 - player.width // 2) % 256
    garden.bloom(garden.seeds.spawn(x=player.x, y=10), player)
    step(count=90)
garden.dreamer.x = 247
garden.friend.x = 55
for index, depth in enumerate((20, 40, 60, 80, 110, 130, 150)):
    garden.seeds.spawn(x=(index * 37 + 20) % 256, y=depth, frame=index % 4)
capture(garden, 'dream-garden.png', 'Populated final game, grown through its bloom handler.')
step(fixture.A)
capture(garden, 'shared-rest.png', 'Player one holds A: RELAX, sleeping pose and slower seeds.')
step(fixture.B)
capture(director.scene_stack[-1], 'dream-rest.png', 'Actual final Rest scene preserves the planted flowers.')
capture(start('01-steering'), 'first-game.png', 'Actual first steering checkpoint, with only one dreamer.')
capture(start('06-tiles'), 'tilemaps.png', 'Actual cloud tilemap checkpoint before scrolling.')


class Angles(vs2.Scene):
    def build(self):
        world = self.layer('world', projection=vs2.TUNNEL)
        for x in (0, 64, 128, 192):
            world.sprite('dreamer.png', x=x - 9, y=0)


class Projections(vs2.Scene):
    def build(self):
        for name, projection, centre in (('tunnel', vs2.TUNNEL, 128), ('hud', vs2.HUD, 0)):
            layer = self.layer(name, projection=projection)
            for index, y in enumerate((0, 24, 48)):
                layer.sprite('dreamer.png', x=centre + index * 32 - 41, y=y)


class Legibility(vs2.Scene):
    def build(self):
        hud = self.layer('hud', projection=vs2.HUD)
        for y in (1, 35):
            hud.label('steel8x8.png', columns=5, x=108, y=y,
                      flip_x=True, flip_y=True, text='RELAX')


for cls, filename in ((Angles, 'display-angles.png'),
                      (Projections, 'display-projections.png'),
                      (Legibility, 'budgets-legibility.png')):
    start().switch(cls())
    step()
    capture(director.scene_stack[-1], filename, 'Geometry example using real Dream Garden assets.')
options.out.write_text(json.dumps(frames))
reset_runtime()
print(f'Exported {len(frames)} scenes to {options.out}')
