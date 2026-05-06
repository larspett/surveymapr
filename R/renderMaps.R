
#' Creates a Render Function to Render qmd Templates
#'
#' @param siteid site id for each locale where the transects or points are.
#' @param sites the path to the data file with siteid and coordinates for transects
#'   and points.
#' @param county character; the county where the survey take place
#' @param output the output directory path, default to working directory
#' @import quarto
#' @import glue
#'
#' @noRd

render_locals <- function(siteid, sites, county, output = getwd()) {


  quarto_render(input = glue("{output}/Transect_maps.qmd"),
                output_format = "all",
                execute_params = list(faltid = siteid,
                                      dat = sites,
                                      lankod = county,
                                      directory = output
                ),
                output_file = glue::glue("{siteid}.pdf"), ##TODO: Perhaps add the site name instead of ID in the pdf name
                cache_refresh = T)

  # cache <- list.files(path = system.file("extdata/Transect_maps_cache/", package = "surveymapR"), full.names = T, recursive = T)
  # mapfile <- list.files(path = system.file("extdata/Transect_maps_files/", package = "surveymapR"), full.names = T, recursive = T)
  # mapsfile <- list.files(path = system.file("extdata/maps", package = "surveymapR"), full.names = T, recursive = T)
  cache <- list.files(path = glue("{output}/Transect_maps_cache"), full.names = T, recursive = T)
  mapfile <- list.files(path = glue("{output}/Transect_maps_files"), full.names = T, recursive = T)
  mapsfile <- list.files(path = glue("{output}"), pattern = ".png|.html|.qmd", full.names = T, recursive = T)

  file.remove(cache)
  file.remove(mapfile)
  file.remove(mapsfile)

}


#' Render the Maps for Your Sites
#'
#' This function takes a list of sites with coordinates of transects, or points and makes
#' maps from this.
#'
#' @param sites a path to a semi-colon separated csv file with sites with transect or
#'   point coordinates in WKT format
#' @param siteID optional; site id for the sites you want. If not given it use all id in
#'   the `sites` file
#' @param county character; the county name of the county your survey is situated in
#' @param output the output directory path, default to working directory
#'
#' @import dplyr
#' @import glue
#' @importFrom readr read_csv2
#' @importFrom purrr walk possibly
#'
#' @return a pdf with an overview map and zoomed in maps on the transects or points.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' render_map(sites = "data/lokaler.csv", county = "Skåne")
#' }

render_map <- function(sites = NULL, siteID = NULL, county = NULL, output = getwd()) {

  if (is.null(county)) {
    stop("\n\n'county' is empty! \nYou must state in which county the locales are situated")
  }
  # set site source
  if (is.null(sites)) {
    site <- lokaler
  }else {
    site <- read_csv2(sites)
  }

  # Set site ids
  if (is.null(siteID)) {
    siteid <- site %>%
      distinct(sit_aggregated) %>%
      pull()
  }else {
    siteid <- site %>%
      distinct(sit_aggregated) %>%
      filter(sit_aggregated %in% siteID) %>%
      pull()
  }

  input <- system.file("extdata", "Transect_maps.qmd", package = "surveymapR")
  file.copy(from = input, to = output)
  # run trough all site-ids and sites
  walk(siteid, possibly(~render_locals(siteid=.x, sites=sites, county = county, output = output), otherwise = "Redo"), .progress = "Creating maps") # The 'possibly' hinder the function to stop if some of the site maps does not work

}

