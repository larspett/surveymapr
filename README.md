README
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

# surveymapR

<!-- badges: start -->

![](https://img.shields.io/gitlab/v/release/universitetet%2Fsurveymapr?sort=date&display_name=release&date_order_by=released_at&style=plastic&logo=R&logoColor=%23276DC3&logoSize=auto&label=surveymapR&labelColor=green)
![](https://img.shields.io/gitlab/license/universitetet%2Fsurveymapr?style=plastic&logo=GNU&logoColor=%23A42E2B&logoSize=auto&label=License&labelColor=blue&color=orange)

![](https://img.shields.io/gitlab/issues/open/universitetet%2Fsurveymapr?style=plastic&logo=gitlab&logoColor=%23FC6D26&logoSize=auto&color=green)
<!-- badges: end -->

This package creates maps with transect and slinga surveys and a
overview map with both, for the Swedish Butterfly Monitoring Project. It
take the coordinates from a csv files, should be semi-colon separated,
with WKT coordinates and the local id and aggregate id, also the local
name, stating if it is a transect or slinga.

## Installation

You can install the package from GitLab with the `install_gitlab()`
function from `remotes` package.

``` r

remotes::install_gitlab('universitetet/surveymapr')
```

## Usage

Your csv file with WKT coordinates should contain the variables
`site_uid`, `sit_aggregate`, `sit_name`,`geo_seg_sequence`, and
`geo_geom`. These are coming from the SQL-database of butterfly
monitoring data.

``` r

render_map(sites = "data/sites.csv", county = "Skåne")
```

If the function fail to render all maps, try to run it with each single
of the site ids. Someties it works if you run it again.

``` r

render_map(siteID = 1864, sites = "data/sites.csv", county = "Östergötland")
render_map(siteID = 1856, sites = "data/sites.csv", county = "Östergötland")
```
