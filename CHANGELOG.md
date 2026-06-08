# Changelog

All notable changes to this project are documented here.
Format: `vMAJOR.MINOR.PATCH — YYYY-MM-DD`

- **MAJOR:** Breaking change or complete redesign
- **MINOR:** New feature or significant improvement  
- **PATCH:** Bug fix, data update, or minor tweak

---

## Unreleased

### Bug fixes
- Replaced `lazyLoad()` with `loadNamespace()` for reliable sysdata loading on non-compiled installs
- Fixed cleanup pattern in `render_locals()` which deleted `Transect_maps.qmd` after first site, causing all subsequent sites to fail
- Fixed `file.copy()` to use `overwrite = TRUE` so updated templates are always applied
- Removed Thunderforest tile provider from overview map (requires paid API key); replaced with OpenStreetMap

### Improvements
- Slingor and Transekter maps now zoom correctly to their own feature extent using `fitBounds()`
- Site labels added as white header strips above each aerial map using `magick`
- Overview page composited from three maps (Overview + County + combined aerial) using `magick`, replacing unreliable Quarto layout block
- Standard SeBMS data (without "slinga"/"transekt" in site names) now supported — all features treated as slingor when neither keyword is detected
- Auto-detection of CSV delimiter (semicolon or comma) added to `render_map()`
- Added `CHANGELOG.md` and `DECISIONS.md` templates for project documentation

### Dependencies
- `magick` activated (was listed in DESCRIPTION but commented out)
- `mapview`, `glue`, `readr`, `quarto` added to `Imports` in DESCRIPTION
- `webshot2`, `widgetframe`, `lubridate`, `RColorBrewer` removed from `Imports` (unused)

---

## v0.3.0 — 2025-05-12
- Initial public version