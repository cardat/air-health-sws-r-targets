#' Create ggplot map of sf object
#' 
#' @param An sf object with value to be plotted in "attributable" field
#' 
#' @return A ggplot2 plot of the sf objects, colour and fill by field "attributable". Faceted by year (if more than one).

viz_map_an <- function(sf, field){
  bounds <- st_bbox(sf)
  ggplot(sf) + 
    geom_sf(mapping = aes(fill = attributable, col = attributable), lwd = 0) +
    facet_grid(~year) +
    scale_fill_viridis_c() + scale_colour_viridis_c() + 
    coord_sf(xlim = c(bounds$xmin, bounds$xmax), ylim = c(bounds$ymin, bounds$ymax), expand = TRUE)
}