do_env_exposure <- function(exposure, sf_geog, variable){
  
  sf_geog_geom <- sf_geog[!sf::st_is_empty(sf_geog), ]
  geog_gid<- data.table::as.data.table(sf_geog_geom)
  geog_gid[, geometry := NULL]
  
  e <- exactextractr::exact_extract(exposure, sf_geog_geom, fun = "mean")
  names(e) <- gsub(".*([0-9]{4}).*", "\\1", names(e))
  
  dt <- data.table::data.table(
    geog_gid
  )
  if(!is.na(variable)){
    dt[, variable := variable]
  }
  dt <- cbind(dt, e)
  
  # to long format
  dt <- data.table::melt(dt, measure.vars = names(e), variable.name = "year", value.name = "value")
  
  return(dt)
}

# ls_exposure <- tar_read(tidy_data_exposure)
# str(ls_exposure, max.level = 2)
# sf_geog <- tar_read(tidy_data_geog)
# dt_exp_pop <- tar_read(tidy_data_exp_pop)
