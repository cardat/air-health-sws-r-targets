do_tidy_geom_mb_2016 <- function(infile_abs_mb_2016){
  # read
  sf_geo <- sf::st_read(infile_abs_mb_2016)
  sf_geo <- sf_geo[, c("MB_CODE16", "SA1_MAIN16", "SA2_MAIN16")]
  
  # standardise geometry attributes
  sf_geo <- st_cast(sf_geo, "MULTIPOLYGON")
  sf_geo <- st_transform(sf_geo, 4283)
  
  names(sf_geo) <- tolower(names(sf_geo))
  return(sf_geo)
}