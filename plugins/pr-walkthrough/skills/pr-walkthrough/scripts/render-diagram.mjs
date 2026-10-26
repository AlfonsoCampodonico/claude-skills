#!/usr/bin/env node
// Render a Mermaid file to SVG with pele, then to PNG with resvg. Node only, no browser.
// Usage: render-diagram.mjs <in.mmd> <out-basename>   → writes <out>.svg and <out>.png
// Dependencies install once, pinned, into ~/.cache/pr-walkthrough (no install scripts run).
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

const DEPS = ['pele@1.10.0', '@resvg/resvg-js@2.6.2'];

const [input, out] = process.argv.slice(2);
if (!input || !out) {
  console.error('usage: render-diagram.mjs <in.mmd> <out-basename>');
  process.exit(2);
}

const cache = join(process.env.XDG_CACHE_HOME || join(homedir(), '.cache'), 'pr-walkthrough');
const stamp = join(cache, `.deps-${DEPS.join('+').replace(/[@/]/g, '_')}`);
if (!existsSync(stamp)) {
  mkdirSync(cache, { recursive: true });
  if (!existsSync(join(cache, 'package.json'))) writeFileSync(join(cache, 'package.json'), '{"private":true}\n');
  execFileSync('npm', ['install', '--no-audit', '--no-fund', '--ignore-scripts', '--silent', ...DEPS], { cwd: cache, stdio: 'inherit' });
  writeFileSync(stamp, '');
}

const { render } = await import(pathToFileURL(join(cache, 'node_modules/pele/dist/pele.js')));
const { Resvg } = createRequire(join(cache, 'package.json'))('@resvg/resvg-js');

const { svg } = render(readFileSync(input, 'utf8'), { links: true });
writeFileSync(`${out}.svg`, svg);

// pele themes through CSS variables with fallbacks; resvg can't resolve var(), so inline the fallbacks.
const vars = {};
for (const m of svg.matchAll(/(--_[a-z]+):var\(--pele-[a-z-]+,([^)]+)\)/g)) vars[m[1]] = m[2];
const flat = svg
  .replace(/var\((--_[a-z]+)\)/g, (_, v) => vars[v] ?? 'black')
  .replace(/var\(--pele-[a-z-]+,([^)]+)\)/g, '$1');

const png = new Resvg(flat, {
  fitTo: { mode: 'zoom', value: 2 },
  background: 'white',
  font: { loadSystemFonts: true },
}).render().asPng();
writeFileSync(`${out}.png`, png);
console.log(`${out}.svg\n${out}.png`);
