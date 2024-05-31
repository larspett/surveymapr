
#' Creates a Render Function to Render qmd Templates
#'
#' @param siteid site id for each locale where the transects or points are.
#' @param data the path to the data with siteid and coordinates for transects
#'   and points.
#' @param county character; the county where the survey take place
#' @import quarto
#'
#' @noRd

render_locals <- compiler::cmpfun(function(siteid, sites, county) {

  quarto_render(input = "./Transect_maps.qmd",
                output_format = "all",
                execute_params = list(faltid = siteid,
                                      dat = sites,
                                      lankod = county),
                output_file = glue::glue("{siteid}.pdf"), ##TODO: Perhaps add the site name instead of ID in the pdf name
                cache_refresh = T)

}
)

#' Render the Maps for Your Sites
#'
#' This function takes a list of sites with coordinates of transects, or points
#' and makes maps from this.
#'
#' @param sites a path to a semicolon separated csv file with sites with
#'   transect or point coordinates to use
#' @param siteID site id for the sites you want
#' @param county character; the county name of the county your survey is
#'   situated in
#'
#' @import dplyr
#' @importFrom readr read_csv2
#' @importFrom purrr walk2 possibly
#'
#' @return a pdf with an overview map and zoomed in maps on the transects or
#'   points.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' render_map("data/lokaler.csv")
#' }

render_map <- function(sites=NA, siteID = NA,  county) {

  if (is.na(sites)) {
    site <- lokaler
  }else {
    site <- read_csv2(sites)
  }

  if (is.na(siteID)) {

    siteid <- site %>%
      distinct(sit_aggregated) %>%
      pull()

  }else {

    siteid <- site %>%
      distinct(sit_aggregated) %>%
      filter(sit_aggregated %in% siteID) %>%
      pull()

  }
  walk2(siteid, sites, possibly(~render_locals(siteid=.x, sites=.y, county = county), otherwise = "Redo"), .progress = "Creating maps") # The 'possibly' hinder the function to stop if some of the site maps does not work

}

