do_tidy_geom_sa2_2016 <- function(infile_abs_sa2_2016){
  sf_geo <- lapply(infile_abs_sa2_2016, st_read)
  # combine 
  sf_geo <- do.call(rbind, sf_geo)
  row.names(sf_geo) <- NULL
  
  sf_geo <- sf_geo[, c("SA2_MAIN16", "SA2_NAME16", "STE_CODE16")]
  
  # standardise geometry attributes
  sf_geo <- st_cast(sf_geo, "MULTIPOLYGON")
  sf_geo <- st_transform(sf_geo, 4283)
  
  # lower case names
  names(sf_geo) <- tolower(names(sf_geo))
  return(sf_geo)
}