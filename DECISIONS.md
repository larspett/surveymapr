# Design & Technical Decisions

This file logs significant decisions made during development, with rationale.
Update it whenever a non-obvious choice is made.

## Format
**YYYY-MM-DD — Decision title**
- **What:** Brief description of the decision
- **Why:** Rationale, alternatives considered
- **Impact:** What this affects

---

## 2026-06-08 — Datasource-driven display mode

- **What:** Display mode (`slinga`, `slinga_transekt`, `transekt`) is derived from `sit_typ_datasourceid` in the data, rather than inferred from site name keywords at render time.
- **Why:** Keyword heuristics ("transekt"/"sling" in `sit_name`) are fragile and only coincidentally correct. The datasource ID is a reliable, structured field that encodes the survey type.
- **Impact:** `render_map()` validates datasource on load and passes display mode explicitly to the QMD template. Unknown or mixed datasources abort with an informative message.

## 2026-06-08 — sit_name keyword detection retained for slinga_transekt datasources

- **What:** For datasources 59, 60, 61, 63, 65, 81, 129 (Slinga + Transekt), individual features are still distinguished by "transekt"/"sling" suffix in `sit_name`.
- **Why:** The data model does not yet have a dedicated column encoding feature type within a site. The name suffix is a stable convention for these datasources but is not ideal.
- **Impact:** If site names deviate from the convention, the wrong features may be rendered. A dedicated `sit_feature_type` column in the data model would make this robust — flagged as a TODO.

## 2026-06-08 — Punktlokal datasources deferred

- **What:** Datasources yielding Punktlokal geometry (polygons) are recognised but not yet rendered.
- **Why:** Point/polygon rendering requires different map logic. Deferring until the use case is confirmed.
- **Impact:** Calling `render_map()` with a Punktlokal datasource will abort with a "not yet supported" message once the datasource list is populated.

## 2026-06-09 — Landscape page 2 via PDF merge rather than LaTeX rotation

- **What:** The landscape second page is generated as a separate PNG (1200×850px), converted to an A4 landscape PDF by magick, and merged with the portrait PDF using `pdftools::pdf_combine()`.
- **Why:** All LaTeX-based approaches (`pdflscape`, `lscape`, `\newgeometry`, `etoolbox` patching) either produced a blank intermediate page, rotated content without rotating the page, or broke in LuaLaTeX. PDF merging sidesteps LaTeX geometry entirely and gives guaranteed correct page dimensions.
- **Impact:** `pdftools` added as a dependency. The QMD writes a flag file (`.landscape_merge`) that `render_locals()` reads after Quarto finishes to trigger the merge and cleanup.

## 2026-06-09 — Chrome cleanup between batch renders

- **What:** A 5-second sleep and `pkill` of Chrome processes is added at the start of each `render_locals()` call.
- **Why:** `mapshot2`/`webshot2` leaves a headless Chrome process running after each Quarto render. When rendering multiple sites in a batch, the second site's Chrome times out because the first site's Chrome is still alive. Since Chrome runs inside a Quarto subprocess, it cannot be closed via R's Chromote API from the parent process.
- **Impact:** Adds ~5 seconds overhead per site. `pkill` targets `Google Chrome for Testing` and `chromium` — may need adjustment on non-Mac platforms.



- **What:** If a CSV contains rows from more than one `sit_typ_datasourceid`, `render_map()` aborts immediately.
- **Why:** Different datasources imply different display logic. Silently mixing them would produce incorrect maps. The user should provide clean, single-datasource input files.
- **Impact:** Users must split multi-datasource exports before rendering.
