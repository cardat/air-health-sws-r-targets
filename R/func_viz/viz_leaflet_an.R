#' Create leaflet map of sf object
#' 
#' @param sf object to be plotted, containing a field 'attributable'
#'
#' @return A leaflet plot of the sf object.

viz_leaflet_an <- function(sf_an){
  # get bounds of sf object
  bounds <- st_bbox(sf_an)
  
  # palette for attributable number
  pal1 <- colorQuantile(
    palette = "RdYlBu",
    domain = sf_an$attributable, n = 5, reverse = TRUE
  )
  
  pal2 <- colorNumeric(
    palette = "Spectral", reverse = TRUE,
    domain = sf_an$pm25
  )
  
  suburb_popup <- paste0(
    "<strong>SA2: </strong>", sf_an$sa2_name16,
    "<br><strong>Attributable excess risk: </strong>", sprintf("%.3f", sf_an$attributable),
    "<br><strong>PM2.5: </strong>", sprintf("%.2f", sf_an$pm25)
  )
  
  ## Note that using addProviderTiles in a target of a targets pipeline causes an error when reading back:
  # Error in copyDependencyToDir(dep, libdir, FALSE) : 
  # Can't copy dependency files that don't exist: 'C:/Users/Username/AppData/Local/Temp/RtmpKQDZb6/leaflet-providers_1.9.0.js'
  ## So add the provider tile when reading the target back
  map <- leaflet(data = sf_an) %>% 
    # addProviderTiles("CartoDB.Positron") %>%
    addPolygons(fillColor = ~pal2(pm25), 
                fillOpacity = 0.6, 
                color = "#BDBDC3", 
                weight = 1, 
                popup = suburb_popup,
                group = "PM25") %>%
    addPolygons(fillColor = ~pal1(attributable), 
                fillOpacity = 0.6, 
                color = "#BDBDC3", 
                weight = 1, 
                popup = suburb_popup,
                group = "Excess risk") %>%
    addLayersControl(
      baseGroups = c("PM25","Excess risk"),
      options = layersControlOptions(collapsed = FALSE)
    )  %>%    
    addLegend("topright", pal = pal2, values = ~pm25,
              title = "PM2.5 (ug/m3)",
              opacity = 1
    ) %>%
    addLegend("topright", pal = pal1, values = ~attributable,
              title = "Excess risk (percentile of non-zero values)",
              opacity = 1
    ) %>%
    addScaleBar("bottomright", options = scaleBarOptions(metric = T)) %>%
    fitBounds(bounds[["xmin"]], bounds[["ymin"]], bounds[["xmax"]], bounds[["ymax"]])
  
  map
}