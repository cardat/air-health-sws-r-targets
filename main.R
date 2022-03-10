library(targets)
library(tarchetypes)

source("R/pipelines/write_pipeline_perth.R")

write_pipeline_perth(preset = "Perth_2014_2016")

# #### Debug ####
# library(data.table)
# library(sf)
# library(raster)
# library(exactextractr)
# 

# tar_destroy()
# tar_manifest()
# tar_read(data_exp_pop)

# tar_option_set(debug = "health_impact_function")
# tar_make(names = health_impact_function, callr_function = NULL)


# tar_manifest(fields = "command")
# tar_glimpse(targets_only = FALSE)

#### Run ####
tar_make() # run pipeline
tar_visnetwork(targets_only = T)

## see results of specified target
library(sf)
library(leaflet)
library(dplyr)
tar_load(make_map_an) 
str(make_map_an)
tar_load(tidy_geom_sa2_2016) ## whoops no geom
tar_load(infile_abs_sa2_2016)
tidy_geom_sa2_2016 <- st_read(infile_abs_sa2_2016[[2]])
names(tidy_geom_sa2_2016) <- tolower(names(tidy_geom_sa2_2016))
tidy_geom_sa2_2016v2 <- left_join(tidy_geom_sa2_2016, make_map_an, by = "sa2_main16")
plot(st_geometry(tidy_geom_sa2_2016v2))
plot(tidy_geom_sa2_2016v2["attributable"])

tar_load(data_linked_pop_health_enviro)
str(data_linked_pop_health_enviro)
data_linked_pop_health_enviro_v2 <- data_linked_pop_health_enviro[,.(pm25 = mean(x)), by = .(sa2_main16)]
tidy_geom_sa2_2016v3 <- left_join(tidy_geom_sa2_2016v2, data_linked_pop_health_enviro_v2, by = "sa2_main16")
names(tidy_geom_sa2_2016v3)

pal1 <- colorQuantile(
  palette = "RdYlBu",
  domain = tidy_geom_sa2_2016v3$attributable, n = 5, reverse = TRUE
)

pal2 <- colorNumeric(
  palette = "Spectral", reverse = TRUE,
  domain = tidy_geom_sa2_2016v3$pm25
)

suburb_popup <- paste0(
  "<strong>SA2: </strong>", tidy_geom_sa2_2016v2$sa2_name16.x,
  "<br><strong>Attributable excess risk: </strong>", sprintf("%.3f", tidy_geom_sa2_2016v3$attributable),
  "<br><strong>PM2.5: </strong>", sprintf("%.2f", tidy_geom_sa2_2016v3$pm25)
  )

leaflet(data = tidy_geom_sa2_2016v3) %>% 
  addProviderTiles("CartoDB.Positron") %>%
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
  setView(115.857048,  -31.953512, zoom = 10)
#browseURL("index.html")
