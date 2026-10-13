#!/usr/bin/env python3
"""Check talk pacing, hosted assets, and the runnable first-game example."""
import argparse
import importlib.util
import hashlib
import json
from html.parser import HTMLParser
from pathlib import Path
import re
import zipfile
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
    parts = {'intro': 0, 'coding': 0}
    identifiers = set()
    for slide in slides:
        identifier = re.search(r'\.slide: id="([^"]+)"', slide)[1]
        assert identifier not in identifiers, identifier
        identifiers.add(identifier)
        duration = int(re.search(r'data-timing="(\d+)"', slide)[1])
        assert duration > 0, identifier
        part = re.search(r'data-talk-part="([^"]+)"', slide)[1]
        parts[part] += duration
        if part == 'intro':
            assert '```python' not in slide.split('\nNotes:\n')[0], identifier
        notes = slide.split('\nNotes:\n', 1)[1]
        cue = re.search(r'\*\*(\d+):(\d+)–(\d+):(\d+)\.\*\*', notes)
        start = int(cue[1]) * 60 + int(cue[2])
        end = int(cue[3]) * 60 + int(cue[4])
        assert (start, end) == (elapsed, elapsed + duration), identifier
        elapsed = end
    assert parts == {'intro': 12 * 60, 'coding': 15 * 60}, parts
    assert elapsed == 27 * 60, elapsed
    print(f'{len(slides)} slides: 12-minute introduction and 15-minute coding section')


def check_site(site, baseurl, sdk):
    presentation = site / 'presentations/making-games'
    for name in ('index.html', 'handout.html', 'presenter-guide.html',
                 'examples/dream-garden-guide.html', 'examples/artwork.html'):
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
                source = sdk / 'docs' / Path(*relative.parts[1:]).with_suffix('.md')
                assert source.is_file(), (file, url, source)
                continue
            if target.is_dir():
                target /= 'index.html'
            assert target.is_file(), (file, url)
    assert (presentation / 'vendor/reveal/LICENSE').is_file()
    assert (presentation / 'slides.md').read_text() == (TALK / 'slides.md').read_text()
    print('Reading view, notes, deck links and local assets are present')


def check_starter(sdk):
    spec = importlib.util.spec_from_file_location('talk_fixture', sdk / 'tests/test_dream_garden.py')
    fixture = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(fixture)
    case = fixture.DreamGardenTests('test_steering_wraps_and_opposites_cancel')
    case.setUp()
    try:
        game = case.start_file(TALK / 'examples/first_game.py')
        assert game.dreamer.x == -9 and game.dreamer.y == 0
        case.step(fixture.director.JOY_LEFT, count=10)
        assert game.dreamer.x == 1
        case.step(fixture.director.JOY_RIGHT, count=2)
        assert game.dreamer.x == 255
        case.step(fixture.director.JOY_LEFT | fixture.director.JOY_RIGHT)
        assert game.dreamer.x == 255
    finally:
        case.tearDown()
    game_source = sdk / 'games/demos/dream_garden'
    assert (TALK / 'examples/dream_garden.py').read_bytes() == (game_source / 'code/dream_garden.py').read_bytes()
    with zipfile.ZipFile(TALK / 'examples/dream-garden.zip') as archive:
        expected = {str(path.relative_to(sdk)): path for path in game_source.rglob('*')
                    if path.is_file() and '__pycache__' not in path.parts
                    and not path.name.endswith('.mp3.wav')}
        expected['games/demos/dream_garden/LICENSE'] = sdk / 'LICENSE'
        expected['tests/test_dream_garden.py'] = sdk / 'tests/test_dream_garden.py'
        assert set(archive.namelist()) == set(expected)
        for name, path in expected.items():
            assert archive.read(name) == path.read_bytes(), name
    print('Starter steers and wraps; complete game source and asset archive match the SDK')


def check_checkpoints(site, sdk):
    stages = set()
    launches = 0
    for slide in (TALK / 'slides.md').read_text().split('\n---\n'):
        content = slide.split('\nNotes:\n')[0]
        if '```python' in content or 'language-python' in content:
            progression = re.search(r'data-progression="([^"]+)"', content)[1]
            assert progression in {'01-steering', '05-flowers', '11-audio'}, progression
        for checkpoint in re.findall(r'data-checkpoint="([^"]+)"', content):
            launches += 1
            path = Path('games/demos/dream_garden/code/checkpoints') / (checkpoint + '.py')
            assert (sdk / path).is_file(), checkpoint
            assert (site / 'emulator' / path).read_bytes() == (sdk / path).read_bytes(), checkpoint
            stages.add(checkpoint)
    assert stages == {'01-steering', '05-flowers', '11-audio'}, stages
    assert launches == 3, launches
    assert (sdk / 'games/demos/dream_garden/code/checkpoints/11-audio.py').read_bytes() == (sdk / 'games/demos/dream_garden/code/dream_garden.py').read_bytes()
    assert 'idle_timeout' not in (TALK / 'slides.md').read_text()
    print('Exactly three cumulative launch parts match the SDK, including the completed game')


def check_webgl_captures(sdk):
    assets = TALK / 'assets'
    record = json.loads((assets / 'captures.json').read_text())
    source = sdk / 'games/demos/dream_garden/code/dream_garden.py'
    assert record['sourceSha256'] == hashlib.sha256(source.read_bytes()).hexdigest()
    captures = {item['file']: item for item in record['captures']}
    expected = {'dream-garden.png', 'shared-rest.png', 'dream-rest.png',
                'first-game.png', 'tilemaps.png', 'display-angles.png',
                'display-projections.png', 'budgets-legibility.png', 'garden-start.png',
                'garden-title.png', 'garden-planting.png', 'display-arxels.png'}
    assert set(captures) == expected
    for filename, capture in captures.items():
        assert capture['displayBackend'] == 'WebGL2', filename
        assert capture['sceneBackend'] == 'WebGL shader', filename
        assert capture['sha256'] == hashlib.sha256((assets / filename).read_bytes()).hexdigest(), filename
    print('All game and display captures match the recorded WebGL output and completed game source')


def check_catalog_captures():
    assets = TALK / 'assets'
    captures = json.loads((assets / 'catalog-captures.json').read_text())
    assert {capture['slug'] for capture in captures} == {
        'alecu.ventilagon_game', 'alecu.vyruss_vs2', 'vsjam-oct25.2bam_sencom',
        'vsjam-may25.vasura_espacial', 'vsjam-oct25.tincho_vrunner'}
    assert len(captures) == 5
    for capture in captures:
        assert capture['displayBackend'] in ('WebGL', 'WebGL2'), capture['file']
        assert capture['runtime']['adapterSource'] != 'error', capture['file']
        assert capture['playback']['elapsedAfterInputMs'] > 2000, capture['file']
        assert capture['sha256'] == hashlib.sha256((assets / capture['file']).read_bytes()).hexdigest()
    print('Existing alecu and community game images match their recorded WebGL captures')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=Path, required=True)
    parser.add_argument('--sdk', type=Path, required=True)
    parser.add_argument('--baseurl', default='')
    options = parser.parse_args()
    check_pacing()
    check_site(options.site.resolve(), options.baseurl.rstrip('/'), options.sdk.resolve())
    check_starter(options.sdk.resolve())
    check_checkpoints(options.site.resolve(), options.sdk.resolve())
    check_webgl_captures(options.sdk.resolve())
    check_catalog_captures()
