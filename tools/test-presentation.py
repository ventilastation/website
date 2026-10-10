#!/usr/bin/env python3
"""Check talk pacing, hosted assets, and the runnable first-game example."""
import argparse
import importlib.util
from html.parser import HTMLParser
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
TALK = ROOT / 'presentations/making-games'


class References(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.urls = []
        self.feed(text)

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if name in ('src', 'href') and value:
                self.urls.append(value)


def check_pacing():
    slides = (TALK / 'slides.md').read_text().split('\n---\n')
    elapsed = 0
    identifiers = set()
    for slide in slides:
        identifier = re.search(r'\.slide: id="([^"]+)"', slide)[1]
        assert identifier not in identifiers, identifier
        identifiers.add(identifier)
        duration = int(re.search(r'data-timing="(\d+)"', slide)[1])
        assert duration > 0, identifier
        notes = slide.split('\nNotes:\n', 1)[1]
        cue = re.search(r'\*\*(\d+):(\d+)–(\d+):(\d+)\.\*\*', notes)
        start = int(cue[1]) * 60 + int(cue[2])
        end = int(cue[3]) * 60 + int(cue[4])
        assert (start, end) == (elapsed, elapsed + duration), identifier
        elapsed = end
    assert elapsed == 45 * 60, elapsed
    assert int(re.search(r'data-timing="(\d+)"', slides[-1])[1]) == 5 * 60
    print(f'{len(slides)} slides: 40-minute talk and 5 minutes of questions')


def check_site(site, baseurl):
    presentation = site / 'presentations/making-games'
    for name in ('index.html', 'handout.html', 'presenter-guide.html'):
        file = presentation / name
        text = file.read_text()
        assert '{% ' not in text and '{{ ' not in text, file
        for url in References(text).urls:
            parts = urlsplit(url)
            if parts.scheme or parts.netloc or not parts.path:
                continue
            path = unquote(parts.path)
            if path.startswith('/'):
                assert not baseurl or path.startswith(baseurl + '/'), (file, url)
                target = site / path.removeprefix(baseurl).lstrip('/')
            else:
                target = file.parent / path
            # Shared documentation is built separately after Jekyll.
            relative = target.resolve().relative_to(site.resolve())
            if relative.parts and relative.parts[0] == 'docs':
                continue
            if target.is_dir():
                target /= 'index.html'
            assert target.is_file(), (file, url)
    assert (presentation / 'vendor/reveal/LICENSE').is_file()
    assert (presentation / 'slides.md').read_text() == (TALK / 'slides.md').read_text()
    print('Reading view, notes, deck links and local assets are present')


def check_starter(sdk):
    spec = importlib.util.spec_from_file_location('talk_fixture', sdk / 'tests/test_tutorial_steps.py')
    fixture = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(fixture)
    fixture.STEPS = str(TALK / 'examples')
    case = fixture.TutorialStepTests('test_step1_steers_the_ship')
    case.setUp()
    try:
        game = case.start('first_game.py')
        assert game.ship.x == -9 and game.ship.y == 0
        case.step(fixture.director.JOY_LEFT, 10)
        assert game.ship.x == 1
        case.step(fixture.director.JOY_RIGHT, 2)
        assert game.ship.x == 255
        case.step(fixture.director.JOY_LEFT | fixture.director.JOY_RIGHT)
        assert game.ship.x == 255
    finally:
        case.tearDown()
    assert (TALK / 'examples/trench_run.py').read_bytes() == (sdk / 'games/demos/tutorial_game/code/tutorial_game.py').read_bytes()
    print('Starter builds, steers, wraps and cancels opposite input; finished example matches the SDK')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=Path, required=True)
    parser.add_argument('--sdk', type=Path, required=True)
    parser.add_argument('--baseurl', default='')
    options = parser.parse_args()
    check_pacing()
    check_site(options.site.resolve(), options.baseurl.rstrip('/'))
    check_starter(options.sdk.resolve())
