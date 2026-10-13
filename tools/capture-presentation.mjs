// Capture slide images with the SDK's actual WebGL scene and LED renderers.
// Install playwright, then:
// python3 tools/presentation-scenes.py --sdk vsdk --out /tmp/garden-scenes.json
// node tools/capture-presentation.mjs vsdk /tmp/garden-scenes.json
// CHROMIUM can select an installed Chrome executable.
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import crypto from 'node:crypto';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
const { chromium } = createRequire(import.meta.url)('playwright');
const sdk = path.resolve(process.argv[2] || 'vsdk');
const frames = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const out = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../presentations/making-games/assets');
const html = `<!doctype html><style>
body { margin:0; background:#0b1016 }
canvas { display:block; width:900px; height:900px; border-radius:50% }
</style><canvas id="display"></canvas><script type="module">
import '/web/led-render-core.js';
import { LedRingWebGLRenderer } from '/web/led-ring-renderers.js';
import { decodeImageStripPayload } from '/web/app-support.js';
const bytes = b64 => Uint8Array.from(atob(b64), c => c.charCodeAt(0));
const renderer = new LedRingWebGLRenderer(document.querySelector('canvas'));
if (!renderer.available || !renderer.isWebGL2) throw Error('WebGL2 is required. No 2D fallback.');
renderer.resolutionScale = 1;
let input;
window.captureScene = frame => {
  input = { sceneKind:'vs2', sceneBytes:bytes(frame.scene), palette:bytes(frame.palette),
    assetIndex:new Map(frame.strips.map(s => [s.slot, decodeImageStripPayload(s.slot, bytes(s.data))])),
    assetVersion:frame.name, paletteVersion:frame.name, starfield:false, frameNumber:0, columnOffset:0 };
  if (!renderer.renderScene(input)) throw Error('WebGL scene composition failed');
  renderer.gl.finish();
  if (renderer.gl.getError()) throw Error('WebGL error');
  const pixels = renderer.sceneCompositor.readPixels();
  if (!pixels.some((c, i) => i % 4 !== 3 && c > 20)) throw Error('Empty game frame');
  const debug = renderer.gl.getExtension('WEBGL_debug_renderer_info');
  return {displayBackend:'WebGL2', sceneBackend:'WebGL shader',
    gpu:debug ? renderer.gl.getParameter(debug.UNMASKED_RENDERER_WEBGL) : 'WebGL2',
    width:renderer.canvas.width, height:renderer.canvas.height};
};
function draw() { if (input) renderer.renderScene(input); requestAnimationFrame(draw); }
draw();
</script>`;
const server = http.createServer((req, res) => {
  const pathname = new URL(req.url, 'http://localhost').pathname;
  if (pathname === '/') { res.setHeader('Content-Type', 'text/html'); res.end(html); return; }
  const file = path.resolve(sdk, '.' + pathname);
  if (!file.startsWith(path.join(sdk, 'web') + path.sep) || !fs.existsSync(file)) {
    res.writeHead(404); res.end(); return;
  }
  res.setHeader('Content-Type', 'text/javascript');
  res.end(fs.readFileSync(file));
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
let browser;
try {
  browser = await chromium.launch({executablePath:process.env.CHROMIUM || undefined,
    headless:true, args:['--no-sandbox']});
  const page = await browser.newPage({viewport:{width:900,height:900}, deviceScaleFactor:1});
  page.on('pageerror', error => console.error(error));
  await page.goto(`http://127.0.0.1:${server.address().port}/`);
  await page.waitForFunction(() => typeof window.captureScene === 'function');
  const records = [];
  for (const frame of frames) {
    const renderer = await page.evaluate(frame => window.captureScene(frame), frame);
    await page.locator('canvas').screenshot({path:path.join(out, frame.name)});
    const sha256 = crypto.createHash('sha256').update(fs.readFileSync(path.join(out, frame.name))).digest('hex');
    records.push({file:frame.name, description:frame.description, ...renderer, sha256});
    console.log(`Captured ${frame.name} with ${renderer.displayBackend} and ${renderer.sceneBackend}`);
  }
  const sourceSha256 = crypto.createHash('sha256').update(fs.readFileSync(path.join(sdk,
    'games/demos/dream_garden/code/dream_garden.py'))).digest('hex');
  fs.writeFileSync(path.join(out, 'captures.json'), JSON.stringify({sourceSha256,captures:records},null,2)+'\n');
} finally {
  if (browser) await browser.close();
  await new Promise(resolve => server.close(resolve));
}
