do_env_exposure <- function(exposure, sf_geog, variable){
  
  sf_geog_geom <- sf_geog[!sf::st_is_empty(sf_geog), ]
  geog_gid<- data.table::as.data.table(sf_geog_geom)
  geog_gid[, geometry := NULL]
  
  e <- exactextractr::exact_extract(exposure, sf_geog_geom, fun = "mean")
  
  ## construct data table for merged data
  dt <- data.table::data.table(
    geog_gid
  )
  if(!is.na(variable)){
    dt[, variable := variable]
  }
  
  ## attach extracted exposures
  e <- as.data.table(e)
  names(e) <- gsub(".*([0-9]{4}).*", "\\1", names(exposure))
  dt <- cbind(dt, e)
  
  # to long format
  dt <- data.table::melt(dt, measure.vars = names(e), variable.name = "year", value.name = "value")
  
  return(dt)
}

# exposure <- tar_read(tidy_env_exposure)
# str(exposure, max.level = 2)
# sf_geog <- tar_read(tidy_geom_mb_2016)
# variable <- "pm25"
