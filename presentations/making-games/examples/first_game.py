"""A complete starter for games/myname/mygame/code/mygame.py.

Also provide images/ship.png, images/__images__.yaml (frames: 3),
menu.png (64 x 30), and VS2 metadata as shown in the presentation.
Run with ./vs-emu.sh --game myname.mygame (vs-emu.bat on Windows).
"""
import vs2
from vs2.controls import LEFT, RIGHT, joy1


class Game(vs2.Scene):
    def build(self):
        world = self.layer("world", projection=vs2.TUNNEL)
        self.ship = world.sprite("ship.png", y=0)
        self.ship.x = -(self.ship.width // 2)

    def update(self):
        steer = joy1.held(LEFT) - joy1.held(RIGHT)
        self.ship.x = (self.ship.x + steer) % vs2.display.width


def main():
    return Game()
