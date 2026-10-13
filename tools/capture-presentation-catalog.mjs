// Real games played in the published emulator, captured with the WebGL display.
// Run after make publish: node tools/capture-presentation-catalog.mjs
// Optional game slugs limit the capture set. CHROMIUM selects installed Chrome.
import fs from 'node:fs';
import path from 'node:path';
import http from 'node:http';
import crypto from 'node:crypto';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
const { chromium } = createRequire(import.meta.url)('playwright');
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const out = path.join(root, 'presentations/making-games/assets');
const games = [
  {slug:'alecu.ventilagon_game', file:'catalog-super-ventilagon.png', title:'Super Ventilagon', keys:['Space'], wait:6500},
  {slug:'alecu.vyruss_vs2', file:'catalog-vyruss.png', title:'Vyruss', keys:[], held:['Space','d'], wait:8500},
  {slug:'vsjam-oct25.2bam_sencom', file:'catalog-senile-command.png', title:'Senile command', keys:['Space'], wait:7000},
  {slug:'vsjam-may25.vasura_espacial', file:'catalog-vasura-espacial.png', title:'Vasura Espacial', keys:[], held:['Space'], wait:6000},
  {slug:'vsjam-oct25.tincho_vrunner', file:'catalog-tincho.png', title:'Tincho el Carpincho', keys:['Space'], wait:4500},
];
const server = http.createServer((req, res) => {
  let file = path.resolve(root, '.' + new URL(req.url,'http://localhost').pathname);
  if (!file.startsWith(root + path.sep)) {res.writeHead(404);res.end();return;}
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file,'index.html');
  if (!fs.existsSync(file)) {res.writeHead(404);res.end();return;}
  const types = {'.html':'text/html','.js':'text/javascript','.mjs':'text/javascript',
    '.css':'text/css','.json':'application/json','.wasm':'application/wasm','.png':'image/png'};
  res.setHeader('Content-Type',types[path.extname(file)] || 'application/octet-stream');
  res.end(fs.readFileSync(file));
});
await new Promise(resolve => server.listen(0,'127.0.0.1',resolve));
let browser;
try {
  browser = await chromium.launch({executablePath:process.env.CHROMIUM || undefined,
    headless:true,args:['--no-sandbox']});
  const records = [];
  for (const game of games.filter(g => !process.argv.slice(2).length || process.argv.slice(2).includes(g.slug))) {
    const context = await browser.newContext({viewport:{width:1280,height:1050},deviceScaleFactor:1});
    const page = await context.newPage();
    page.on('pageerror', e => console.error(game.slug,e.message));
    await page.goto(`http://127.0.0.1:${server.address().port}/emulator/`);
    await page.waitForFunction(() => window.VentilastationWebEmulator,null,{timeout:60000});
    // Historical jam folders contain hyphens. Use the runtime's slug API
    // instead of the URL validator, which currently accepts identifiers only.
    await page.evaluate(slug => window.VentilastationWebEmulator.restartRuntime(
      {full:true,autostartSlug:slug}),game.slug);
    await page.addStyleTag({content:'.stage-fullscreen-toggle,.base-preview{display:none!important}.stage-display::after{display:none!important}#frame-canvas-gl{width:900px!important;height:900px!important;max-width:none!important;max-height:none!important}.stage-display{width:900px!important;height:900px!important;background:#0b1016!important}'});
    await page.waitForTimeout(1800);
    for (const key of game.keys) await page.keyboard.press(key,{delay:90});
    for (const key of game.held || []) await page.keyboard.down(key);
    await page.waitForTimeout(game.wait);
    const info = await page.evaluate(() => {
      const canvas = document.querySelector('#frame-canvas-gl');
      const gl = canvas.getContext('webgl2') || canvas.getContext('webgl');
      if (!gl || getComputedStyle(canvas).display === 'none') throw Error('WebGL display is unavailable');
      const error = document.querySelector('#scene-error-banner');
      if (error && !error.hidden) throw Error(error.textContent);
      const runtime = window.VentilastationWebEmulator.getRuntimeInfo();
      if (runtime.adapterSource === 'error' || runtime.pollingHalted) {
        throw Error('Game runtime failed: '+JSON.stringify(runtime)+' '+document.querySelector('#runtime-message')?.textContent);
      }
      const debug = gl.getExtension('WEBGL_debug_renderer_info');
      return {displayBackend:gl instanceof WebGL2RenderingContext?'WebGL2':'WebGL',
        gpu:debug?gl.getParameter(debug.UNMASKED_RENDERER_WEBGL):'WebGL',runtime};
    });
    await page.evaluate(() => {
      Object.defineProperty(document,'hidden',{configurable:true,get:()=>true});
      document.dispatchEvent(new Event('visibilitychange'));
    });
    await page.waitForTimeout(100);
    await page.locator('#frame-canvas-gl').screenshot({path:path.join(out,game.file)});
    const sha256 = crypto.createHash('sha256').update(fs.readFileSync(path.join(out,game.file))).digest('hex');
    records.push({file:game.file,slug:game.slug,title:game.title,
      playback:{startKeys:game.keys,heldKeys:game.held || [],elapsedAfterInputMs:game.wait},...info,sha256});
    const previous = path.join(out,'catalog-captures.json');
    const existing = fs.existsSync(previous)?JSON.parse(fs.readFileSync(previous,'utf8')):[];
    fs.writeFileSync(previous,JSON.stringify([...existing.filter(e=>e.slug!==game.slug),records.at(-1)],null,2)+'\n');
    console.log(`Captured ${game.title} with ${info.displayBackend}`);
    await context.close();
  }
  const previous = path.join(out,'catalog-captures.json');
  const existing = fs.existsSync(previous)?JSON.parse(fs.readFileSync(previous,'utf8')):[];
  const updated = [...existing.filter(e=>games.some(g=>g.slug===e.slug) && !records.some(r=>r.slug===e.slug)),...records];
  fs.writeFileSync(previous,JSON.stringify(updated,null,2)+'\n');
} finally {
  if (browser) await browser.close();
  await new Promise(resolve => server.close(resolve));
}
