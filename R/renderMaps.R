#' Creates a Render Function to Render qmd Templates
#'
#' @param siteid site id for each locale where the transects or points are.
#' @param sites the path to the data file with siteid and coordinates for transects
#'   and points.
#' @param county character; the county where the survey take place
#' @param datasource integer; the datasource id for the sites
#' @param output the output directory path, default to working directory
#'
#' @import quarto
#' @import glue
#'
#' @noRd

render_locals <- function(siteid, sites, county, datasource, landscape_p2 = FALSE, output = getwd()) {

  # Give any Chrome process from a previous render time to shut down cleanly
  Sys.sleep(5)

  quarto_render(input = glue("{output}/Transect_maps.qmd"),
                output_format = "all",
                execute_params = list(faltid       = siteid,
                                      dat          = sites,
                                      lankod       = county,
                                      datasource   = datasource,
                                      landscape_p2 = landscape_p2,
                                      directory    = output
                ),
                output_file = glue::glue("{siteid}.pdf"),
                cache_refresh = TRUE)

  # If landscape_p2 was requested, merge the landscape PDF as page 2
  merge_flag <- glue("{output}/.landscape_merge")
  if (file.exists(merge_flag)) {
    landscape_pdf <- readLines(merge_flag)
    main_pdf      <- glue("{output}/{siteid}.pdf")
    merged_pdf    <- glue("{output}/{siteid}_merged.pdf")
    pdftools::pdf_combine(c(main_pdf, landscape_pdf), merged_pdf)
    file.rename(merged_pdf, main_pdf)
    file.remove(merge_flag)
  }

  # Force-kill any lingering Chrome processes left by mapshot2/webshot2
  if (.Platform$OS.type == "unix") {
    system("pkill -f 'Google Chrome for Testing' 2>/dev/null || true", ignore.stdout = TRUE, ignore.stderr = TRUE)
    system("pkill -f 'chromium' 2>/dev/null || true", ignore.stdout = TRUE, ignore.stderr = TRUE)
  }
  Sys.sleep(2)

  cache    <- list.files(path = glue("{output}/Transect_maps_cache"), full.names = TRUE, recursive = TRUE)
  mapfile  <- list.files(path = glue("{output}/Transect_maps_files"), full.names = TRUE, recursive = TRUE)
  mapsfile <- list.files(path = glue("{output}"), pattern = "\\.png$|\\.html$", full.names = TRUE, recursive = TRUE)
  landscape_pdf_tmp <- glue("{output}/TransSlingorLandscape.pdf")
  if (file.exists(landscape_pdf_tmp)) file.remove(landscape_pdf_tmp)

  file.remove(cache)
  file.remove(mapfile)
  file.remove(mapsfile)
}


#' Render the Maps for Your Sites
#'
#' This function takes a list of sites with coordinates of transects, or points and makes
#' maps from this.
#'
#' @param sites a path to a csv file with sites with transect or point coordinates
#'   in WKT format. Accepts both semicolon-separated and comma-separated files;
#'   the delimiter is auto-detected from the first line unless \code{sep} is specified.
#' @param siteID optional; one or more site ids to render. If not given, all ids in
#'   the \code{sites} file are used. Example: \code{siteID = c(1000, 1001)}.
#' @param county character; the county name of the county your survey is situated in
#' @param output the output directory path, default to working directory
#' @param landscape_p2 logical; if \code{TRUE} and datasource is slinga-only, a second
#'   page is added to the PDF with the combined aerial map in landscape orientation.
#'   Ignored for slinga+transekt and transekt-only datasources. Default \code{FALSE}.
#' @param sep character; the delimiter used in the csv file (\code{";"} or \code{","}).
#'   If \code{NULL} (default), the delimiter is auto-detected from the first line of the file.
#'
#' @import dplyr
#' @import glue
#' @importFrom readr read_delim
#' @importFrom purrr walk possibly
#'
#' @return a pdf with an overview map and zoomed in maps on the transects or points.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' render_map(sites = "data/lokaler.csv", county = "Skåne")
#' render_map(sites = "data/lokaler.csv", county = "Skåne", siteID = c(1000, 1001))
#' }

render_map <- function(sites = NULL, siteID = NULL, county = NULL, landscape_p2 = FALSE, output = getwd(), sep = NULL) {

  # Known datasource groups
  ds_slinga_only    <- c(54, 55, 56, 66, 67, 84, 118, 131, 167)
  ds_slinga_transekt <- c(59, 60, 61, 63, 65, 81, 129)
  ds_transekt_only  <- c(57)
  ds_punktlokal     <- c()  # reserved for future use — none yet classified
  ds_known          <- c(ds_slinga_only, ds_slinga_transekt, ds_transekt_only)

  if (is.null(county)) {
    stop("\n\n'county' is empty! \nYou must state in which county the locales are situated")
  }

  # Load data
  if (is.null(sites)) {
    site <- lokaler
  } else {
    if (is.null(sep)) {
      first_line <- readLines(sites, n = 1)
      sep <- ifelse(grepl(";", first_line), ";", ",")
    }
    site <- read_delim(sites, delim = sep, show_col_types = FALSE)
  }

  # --- Datasource validation ---

  # Check column exists
  if (!"sit_typ_datasourceid" %in% names(site)) {
    stop("\n\nColumn 'sit_typ_datasourceid' not found in the data file.\n",
         "Please ensure your CSV includes this column.")
  }

  ds_in_data <- unique(site$sit_typ_datasourceid)

  # Check for mixed datasources
  if (length(ds_in_data) > 1) {
    stop("\n\nMultiple datasources found in your data: ", paste(ds_in_data, collapse = ", "), ".\n",
         "Please provide a file with a single datasource only.")
  }

  datasource <- ds_in_data

  # Check for unknown datasource
  if (!datasource %in% ds_known) {
    stop("\n\nDatasource ", datasource, " is not recognised.\n",
         "Supported datasources:\n",
         "  Slinga/Punktlokal only : ", paste(ds_slinga_only, collapse = ", "), "\n",
         "  Slinga + Transekt      : ", paste(ds_slinga_transekt, collapse = ", "), "\n",
         "  Transekt only          : ", paste(ds_transekt_only, collapse = ", "))
  }

  # Punktlokal — not yet supported (placeholder for future geometry check)
  # if (datasource %in% ds_punktlokal) {
  #   stop("\n\nDatasource ", datasource, " is a Punktlokal type and is not yet supported.")
  # }

  # Determine display mode
  display_mode <- dplyr::case_when(
    datasource %in% ds_slinga_only     ~ "slinga",
    datasource %in% ds_slinga_transekt ~ "slinga_transekt",
    datasource %in% ds_transekt_only   ~ "transekt"
  )

  # --- Site ID filtering ---
  if (is.null(siteID)) {
    siteid <- site %>%
      distinct(sit_aggregated) %>%
      pull()
  } else {
    siteid <- site %>%
      distinct(sit_aggregated) %>%
      filter(sit_aggregated %in% siteID) %>%
      pull()

    if (length(siteid) == 0) {
      stop("\n\nNone of the requested siteID values were found in the data.\n",
           "Requested: ", paste(siteID, collapse = ", "))
    }

    missing <- setdiff(siteID, siteid)
    if (length(missing) > 0) {
      warning("The following siteID values were not found in the data and will be skipped: ",
              paste(missing, collapse = ", "))
    }
  }

  # landscape_p2 only applies to slinga-only datasources
  use_landscape_p2 <- landscape_p2 && display_mode == "slinga"

  input <- system.file("extdata", "Transect_maps.qmd", package = "surveymapR")
  file.copy(from = input, to = output, overwrite = TRUE)

  walk(
    siteid,
    possibly(
      ~render_locals(siteid = .x, sites = sites, county = county,
                     datasource = display_mode, landscape_p2 = use_landscape_p2,
                     output = output),
      otherwise = "Redo"
    ),
    .progress = "Creating maps"
  )
}
