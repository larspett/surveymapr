# Changelog

All notable changes to this project are documented here.
Format: `vMAJOR.MINOR.PATCH — YYYY-MM-DD`

- **MAJOR:** Breaking change or complete redesign
- **MINOR:** New feature or significant improvement  
- **PATCH:** Bug fix, data update, or minor tweak

---

## v0.4.0 — 2026-06-08

### New features
- `siteID` parameter now accepts a vector of IDs (e.g. `siteID = c(1000, 1001)`) to render a subset of sites
- Datasource validation added to `render_map()`: datasource is auto-detected from `sit_typ_datasourceid` column in the data
- Display mode (`"slinga"`, `"slinga_transekt"`, `"transekt"`) now derived from datasource ID, replacing unreliable keyword heuristics for slinga-only and transekt-only datasources
- Informative error messages for: missing county, unknown datasource, mixed datasources in one file, requested siteIDs not found in data
- Warning issued for partially matched siteID vectors (some found, some not)

### Design decisions
- For `slinga_transekt` datasources (59, 60, 61, 63, 65, 81, 129), feature type is still determined by `sit_name` keyword ("transekt"/"sling") — this is a known data model limitation, tracked in DECISIONS.md
- Punktlokal datasources reserved for future implementation; will abort with informative message when added

### Supported datasources
- Slinga/Punktlokal only: 54, 55, 56, 66, 67, 84, 118, 131, 167
- Slinga + Transekt: 59, 60, 61, 63, 65, 81, 129
- Transekt only: 57

---

## v0.3.1 — 2026-06-08

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
