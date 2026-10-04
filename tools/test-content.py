#!/usr/bin/env python3
"""Build isolated editing fixtures and check the site's content contracts."""

import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
PAGES = ("index.html", "en/index.html", "links.html")
PRIVATE_PATHS = ("CONTENT.md", "README.md", "README.txt", "DEPLOY.md", "Makefile", "tools", "vsdk")


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.description = None
        self.title = ""
        self.headings = []
        self.images = []
        self.sections = []
        self.links = []
        self._title = False
        self._heading = False
        self.feed(path.read_text())

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if tag == "a":
            self.links.append(attrs.get("href"))
        if tag == "meta" and attrs.get("name") == "description":
            self.description = attrs["content"]
        elif tag == "title":
            self._title = True
        elif tag == "h2":
            self._heading = True
            self.headings.append("")
        elif tag == "img":
            self.images.append(attrs.get("src"))
        elif tag == "section":
            self.sections.append(attrs.get("id"))

    def handle_endtag(self, tag):
        if tag == "title":
            self._title = False
        elif tag == "h2":
            self._heading = False

    def handle_data(self, data):
        if self._title:
            self.title += data
        if self._heading:
            self.headings[-1] += data


def build(source, destination):
    result = subprocess.run(
        ["bundle", "exec", "jekyll", "build", "--source", str(source),
         "--destination", str(destination), "--strict_front_matter"],
        cwd=ROOT, capture_output=True, text=True,
    )
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)


class ContentTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="ventilastation-content-")
        cls.workspace = Path(cls.temp.name)
        cls.source = cls.workspace / "source"
        cls.source.mkdir()
        for directory in ("_contenido", "_includes", "_layouts", "en"):
            shutil.copytree(ROOT / directory, cls.source / directory)
        for filename in ("_config.yml", "index.html", "links.html", "feed.xml"):
            shutil.copy(ROOT / filename, cls.source / filename)
        for name in PRIVATE_PATHS:
            path = cls.source / name
            if path.suffix or name == "Makefile":
                path.write_text("Private source fixture\n")
            else:
                path.mkdir()
                (path / "fixture.txt").write_text("Private source fixture\n")
        (cls.source / "emulator").mkdir()
        (cls.source / "emulator" / "fixture.txt").write_text("Published runtime asset\n")
        cls.baseline = cls.workspace / "baseline"
        build(cls.source, cls.baseline)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def variant(self, name):
        source = self.workspace / name
        shutil.copytree(self.source, source, ignore=shutil.ignore_patterns(".jekyll-cache"))
        return source, self.workspace / (name + "-output")

    def test_line_breaks_survive_whitespace_trimming(self):
        source, output = self.variant("trimmed")
        for filename in source.rglob("*.md"):
            filename.write_text("\n".join(line.rstrip() for line in filename.read_text().splitlines()) + "\n")
        build(source, output)
        for filename in PAGES:
            with self.subTest(page=filename):
                normalize = lambda text: re.sub(r"\s+", " ", text).strip()
                self.assertEqual(normalize((self.baseline / filename).read_text()),
                                 normalize((output / filename).read_text()))

    def test_games_render_without_a_play_section(self):
        source, output = self.variant("english-game")
        game = (source / "_contenido/home_es/juegos/01-vermu.md").read_text()
        game = game.replace("lang: es", "lang: en").replace("images/", "/images/")
        (source / "_contenido/home_en/test-game.md").write_text(game)
        build(source, output)
        page = Page(output / "en/index.html")
        self.assertIn("/images/vermu.png", page.images)
        self.assertIn("/images/vermu-control.png", page.images)
        self.assertEqual(page.sections.count("two"), 2)
        self.assertEqual(Page(self.baseline / "en/index.html").sections.count("two"), 1)

    def test_banner_edits_update_metadata_and_rss(self):
        source, output = self.variant("metadata")
        banner = source / "_contenido/home_es/banner.md"
        front_matter = banner.read_text().split("---", 2)[1]
        banner.write_text('---' + front_matter + '---\nUna descripción "nueva" & [enlace](https://example.org/).\n')
        config = source / "_config.yml"
        config.write_text(re.sub(r"^title:.*$", "title: Título de prueba", config.read_text(), flags=re.M))
        build(source, output)
        for filename in ("index.html", "en/index.html"):
            page = Page(output / filename)
            self.assertEqual(page.title, "Título de prueba")
            self.assertEqual(page.headings[0], "Título de prueba")
            self.assertEqual(page.description, 'Una descripción "nueva" & enlace.')
        channel = ET.parse(output / "feed.xml").getroot().find("channel")
        self.assertEqual(channel.findtext("title"), "Título de prueba")
        self.assertEqual(channel.findtext("description"), 'Una descripción "nueva" & enlace.')

    def test_both_languages_offer_the_same_current_developer_path(self):
        for filename in ("index.html", "en/index.html"):
            page = Page(self.baseline / filename)
            for target in ("/docs/", "/emulator/", "/docs/guides/desktop.html",
                           "/docs/vs2/tutorial/first-game.html", "/docs/vs2/tutorial/index.html",
                           "/docs/vs2/reference/index.html"):
                with self.subTest(page=filename, target=target):
                    self.assertIn(target, page.links)

    def test_private_sources_are_excluded_without_losing_runtime_assets(self):
        for name in PRIVATE_PATHS:
            with self.subTest(path=name):
                self.assertFalse((self.baseline / name).exists())
        self.assertTrue((self.baseline / "emulator/fixture.txt").is_file())


def check_published_site(site):
    for name in PRIVATE_PATHS:
        if (site / name).exists():
            raise RuntimeError(f"Source files were published: {name}")
    for name in ("emulator/index.html", "emulator/runtime-bundle.json",
                 "emulator/runtime-manifest.json", "emulator/vendor/micropython/micropython.wasm",
                 "emulator/games/alecu/vyruss_vs2/code/vyruss_vs2.py",
                 "docs/index.html", "docs/guides/desktop.html",
                 "docs/vs2/tutorial/first-game.html", "docs/vs2/reference/index.html"):
        if not (site / name).is_file():
            raise RuntimeError(f"Missing published emulator asset: {name}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--site", type=Path, help="Also check a complete published Jekyll site")
    options = parser.parse_args()
    if options.site:
        check_published_site(options.site)
    unittest.main(argv=[__file__], verbosity=2)
