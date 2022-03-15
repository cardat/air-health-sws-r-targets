#' Save leaflet map of sf object
#' 
#' 
#' 

viz_map_an <- function(sf, field){
  ggplot(sf) + 
    geom_sf(mapping = aes(fill = attributable, col = attributable), lwd = 0) +
    facet_grid(~year) +
    scale_fill_viridis_c() + scale_colour_viridis_c() #+ 
    
    # coord_sf(xlim = c(115, 117), ylim = c(-33, -31), expand = TRUE) # perth
}