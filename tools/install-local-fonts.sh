#!/usr/bin/env bash
# Install pinned open-source WOFF2 files into PLN's OWN static assets.
# The network is used ONLY once during installation, never by the public site.
# Run from any directory: bash themes/pln/tools/install-local-fonts.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/source/fonts"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

command -v npm >/dev/null || { echo 'Node/npm required (run nvm use in blog root).' >&2; exit 1; }
command -v node >/dev/null || { echo 'Node required.' >&2; exit 1; }

fetch_package() {
    local spec="$1" location="$2" filename
    mkdir -p "$TMP/$location"
    echo "Fetching pinned package: $spec"
    filename="$(npm pack "$spec" --silent --pack-destination "$TMP")"
    test -n "$filename"
    tar -xzf "$TMP/$filename" -C "$TMP/$location" --strip-components=1
}

fetch_package '@fontsource/open-sans-condensed@4.5.5' 'open'
fetch_package '@fontsource/special-elite@5.3.0' 'elite'

FONT_FILES=(
  'open:open-sans-condensed-latin-300-normal.woff2'
  'open:open-sans-condensed-latin-700-normal.woff2'
  'elite:special-elite-latin-400-normal.woff2'
)
for pair in "${FONT_FILES[@]}"; do
    location="${pair%%:*}"
    filename="${pair#*:}"
    src="$TMP/$location/files/$filename"
    if [[ ! -s "$src" ]]; then
        echo "Missing package font: $src" >&2
        echo 'Stop: source SCSS has NOT been changed.' >&2
        exit 1
    fi
    # WOFF2 files have a known four-byte magic number.
    FONT_TO_CHECK="$src" node - <<'NODE'
const fs = require('fs');
const path = process.env.FONT_TO_CHECK;
const file = fs.readFileSync(path);
if (file.length < 512 || file.toString('ascii', 0, 4) !== 'wOF2') {
  console.error('Invalid WOFF2 font: ' + path);
  process.exit(1);
}
NODE
done

# Validate planned source edits BEFORE writing them; support both uploaded
# main.scss and the version with the preceding performance/font import patch.
PLN_ROOT="$ROOT" node - <<'NODE'
const fs = require('fs');
const path = require('path');
const root = process.env.PLN_ROOT;
const mainFile = path.join(root, 'scss/main.scss');
const footerFile = path.join(root, 'scss/footer.scss');
const fontsFile = path.join(root, 'scss/_local-fonts.scss');
if (!fs.existsSync(fontsFile)) throw Error('Missing scss/_local-fonts.scss (extract ZIP first).');
let main = fs.readFileSync(mainFile, 'utf8');
let footer = fs.readFileSync(footerFile, 'utf8');
if (!main.includes('@use "local-fonts";')) {
  const anchor = '@use "animation";';
  if (!main.includes(anchor)) throw Error('Expected main.scss @use "animation" not found; no files changed.');
  main = main.replace(anchor, anchor + '\n@use "local-fonts";');
}
// Remove old one-or-two font @imports (including the single merged import).
const remoteFontImport = /^[ \t]*@import[ \t]+url\([ \t]*['"]?https:\/\/fonts\.googleapis\.com\/css[^\r\n;]*;[ \t]*\r?\n/gm;
main = main.replace(remoteFontImport, '');
if (/fonts\.(googleapis|gstatic)\.com/i.test(main)) {
  throw Error('Unrecognized remote font reference in main.scss; no files changed.');
}
// Font Awesome icon sets its own font-family. Removing Pacifico from the
// arrow's container does not change the arrow shape.
footer = footer.replace(/^[ \t]*font-family:[ \t]*['"]Pacifico['"][^;\r\n]*;[ \t]*\r?\n/gm, '');
if (/Pacifico/i.test(footer)) throw Error('Other Pacifico usage found in footer.scss; no files changed.');
// Atomically replace existing SCSS files in place, retaining ALL other rules.
function replace(file, value) {
  const old = fs.readFileSync(file, 'utf8');
  if (old === value) return;
  const dest = file + '.pln-tmp-' + process.pid;
  fs.writeFileSync(dest, value, { mode: fs.statSync(file).mode });
  fs.renameSync(dest, file);
}
replace(mainFile, main);
replace(footerFile, footer);
console.log('Updated scss/main.scss and scss/footer.scss.');
NODE

mkdir -p "$DEST/LICENSES"
for pair in "${FONT_FILES[@]}"; do
    location="${pair%%:*}"
    filename="${pair#*:}"
    cp "$TMP/$location/files/$filename" "$DEST/$filename"
done
# Include font package license(s), plus separately bundled typeface license.
for location in open elite; do
    if [[ -f "$TMP/$location/LICENSE" ]]; then
        cp "$TMP/$location/LICENSE" "$DEST/LICENSES/Fontsource-$location-LICENSE.txt"
    fi
done

echo
printf 'Installed locally hosted fonts:\n'
ls -lh "$DEST"/*.woff2
printf '\nReview source changes: git -C "%s" diff -- scss/main.scss scss/footer.scss\n' "$ROOT"
echo 'Next: npm run css && npm run build, then test requests in the browser.'
