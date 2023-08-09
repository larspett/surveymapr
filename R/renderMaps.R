
#| label: "Run quarto rendering"
#| eval: false

# Sit_name, sit_aggregated
# 1211:30	- 1762
# 1189:10	- 1702
# 1191.43	- 1722
# Bomhult	- 1806
# 1169:6	- 1680
# 1190:19	- 1710
# 1147:14	- 1672
# 1170:59	- 1688
# 1209:64	- 1756
# Ekön	1812
# 1196:5 - 1750
# Tolefors-Lagerlunda - 1874
# 1193:73	- 1736
# 1212:71	- 1766
# Smedstorp	- 1852
# Galmsås	- 1816
# 1232:50	- 3073
# 1172:23	- 1700
# Stockhult	- 1862
# Öna	- 1878
# Föllingsö	- 1814
# Bösemålen	- 1810
# Staffanstorp	- 1858
# 1193 44	- 1732

## Här får man ut sitenames i filen istället för site_aggregated
# sites <- read_csv("data/ostergotland_rmo.csv") %>%
#   select(sit_aggregated, sit_name) %>%
#   distinct(sit_aggregated, .keep_all = T) %>%
#   mutate(sit_name = str_remove(sit_name, " slinga| transekter"))
#
# for (i in seq_along(sites$sit_aggregated)) {
#   quarto::quarto_render(input = "Transect_maps.qmd", output_format = "all", execute_params = list(faltid = sites[i,1] %>% pull(), siteText = sites[i,2] %>% pull()), output_file = glue::glue("{sites[i,2] %>% pull()}.pdf")) #, lankod = sites[i,3] %>% pull()
#
# }

# Med purr

#' Creates a render function to render qmd templates
#'
#' @param site site id for each locale where the transects or points are.
#'
#' @noRd
render_locals <- compiler::cmpfun(function(site) {

  quarto::quarto_render(input = "Transect_maps.qmd",
                        output_format = "all",
                        execute_params = list(faltid = site),
                        output_file = glue::glue("{site}.pdf"),
                        cache_refresh = T)

}
)

#' Render the Maps for Your Sites
#'
#' This function takes a list of sites with coordinates of transects, or points and makes maps from this.
#'
#' @param sites the list of sites with transect or point coordinates to use
#'
#' @return a pdf with an overview map and zoomed in maps on the transects or points.
#'
#' @export
#'
#' @examples
render_map <- function(sites) {

  sites <- read_csv("data/ostergotland_rmo.csv") %>%
    distinct(sit_aggregated) %>%
    pull()

  sites <- c(1860) # The ones that failed the first round for some reason

  sites %>%
    purrr::walk(possibly(render_locals, otherwise = "Redo")) # The 'possibly' hinder the function to stop if some of the site maps does not work

}
