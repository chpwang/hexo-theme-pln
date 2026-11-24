"use strict";

// PLN: deterministic cache-busting for the compiled primary stylesheet.
// Loaded by Hexo from themes/pln/scripts/ during site generation.
// No browser JavaScript, npm dependency, or build-command changes.
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");

hexo.extend.helper.register("pln_css_version", function () {
  // Hash the exact file Hexo publishes at /css/m.min.css. Calculate on
  // demand so a watch-mode render can also see newly compiled CSS.
  const stylesheet = path.join(hexo.theme_dir, "source", "css", "m.min.css");
  let bytes;
  try {
    bytes = fs.readFileSync(stylesheet);
  } catch (error) {
    throw new Error(
      "[PLN asset version] Cannot read " + stylesheet +
      ". Run 'npm run css' before 'npm run build'. Cause: " + error.message
    );
  }
  return crypto.createHash("sha256").update(bytes).digest("hex").slice(0, 12);
});
