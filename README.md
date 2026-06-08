# surveymapR

<!-- badges: start -->
![](https://img.shields.io/github/v/release/larspett/surveymapr?sort=date&display_name=release&style=plastic&logo=R&logoColor=%23276DC3&label=surveymapR&labelColor=green)
![](https://img.shields.io/github/license/larspett/surveymapr?style=plastic&logo=GNU&logoColor=%23A42E2B&label=License&labelColor=blue&color=orange)
![](https://img.shields.io/github/issues/larspett/surveymapr?style=plastic&logo=github&color=green)
<!-- badges: end -->

`surveymapR` generates field-ready PDF maps for butterfly survey sites. Given a CSV export of site coordinates, it produces a two-page PDF per site: a portrait overview collage (locality map, county map, and combined aerial) and — optionally — a landscape aerial on page 2 for sites where that gives a better view.

Originally developed by Georg Andersson for the Swedish Butterfly Monitoring Scheme (SeBMS). Extended to support multiple datasources and monitoring programmes.

---

## Installation

```r
remotes::install_github("larspett/surveymapr")
```

---

## Input data

Your CSV must contain these columns:

| Column | Description |
|--------|-------------|
| `sit_uid` | Unique site ID |
| `sit_aggregated` | Aggregate site ID (used for grouping) |
| `sit_name` | Site name (includes type suffix for slinga+transekt datasources) |
| `sit_type` | Site type code |
| `sit_typ_datasourceid` | Datasource ID — determines display mode |
| `geo_seg_sequence` | Segment sequence number |
| `geo_geom` | Geometry in EWKB format (SWEREF99TM / EPSG:3006) |

Both semicolon- and comma-separated files are accepted; the delimiter is auto-detected.

---

## Supported datasources

The datasource ID (`sit_typ_datasourceid`) is read from the data and determines how features are rendered. All rows in a file must share the same datasource.

| Mode | Datasource IDs |
|------|---------------|
| Slinga only | 54, 55, 56, 66, 67, 84, 118, 131, 167 |
| Slinga + Transekt | 59, 60, 61, 63, 65, 81, 129 |
| Transekt only | 57 |

Unknown or mixed datasources will produce an informative error.

---

## Usage

### Render all sites in a file

```r
render_map(sites = "data/lokaler.csv", county = "Skåne")
```

### Render specific sites

```r
render_map(sites = "data/lokaler.csv", county = "Skåne", siteID = c(4420, 4429))
```

### Add a landscape page 2

For slinga-only datasources, a second page with the aerial map in landscape orientation can be added. This replaces the portrait Slingor page and gives a better view for wide sites.

```r
render_map(sites = "data/lokaler.csv", county = "Skåne", siteID = 4429, landscape_p2 = TRUE)
```

`landscape_p2` is silently ignored for slinga+transekt and transekt-only datasources.

### Specify output directory

```r
render_map(sites = "data/lokaler.csv", county = "Skåne", output = "output/maps")
```

---

## Output

One PDF per `sit_aggregated` ID, named `<sit_aggregated>.pdf`, written to the output directory.

**Portrait only (`landscape_p2 = FALSE`, default):**
- Page 1: collage of overview map, county map, and combined aerial

**With landscape page 2 (`landscape_p2 = TRUE`, slinga-only datasources):**
- Page 1: portrait collage
- Page 2: landscape aerial with site name header

For slinga+transekt datasources, individual Slingor and Transekter aerial maps are included as additional pages before the collage.

---

## Dependencies

Requires R ≥ 4.1.0. Key dependencies: `sf`, `leaflet`, `mapview`, `magick`, `quarto`, `pdftools`.

A working installation of [Quarto](https://quarto.org) and a Chromium-based browser (used by `webshot2` for map rendering) are also required.

---

## Notes

- For slinga+transekt datasources, feature type (slinga vs transekt) is determined by the `sit_name` suffix. This is a known data model limitation — a dedicated type column is planned.
- Punktlokal datasources (polygon geometry) are not yet supported.
- When rendering large batches, a short delay is introduced between sites to allow the headless browser to release cleanly.
