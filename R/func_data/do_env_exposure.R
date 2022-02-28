do_env_exposure <- function(ls_exposure, sf_geog){
  
  sf_geog_geom <- sf_geog[!sf::st_is_empty(sf_geog), ]
  geog_gid<- data.table::as.data.table(sf_geog_geom)
  geog_gid[, geometry := NULL]
  extr <- #lapply(ls_exposure, function(x) 
    {
      x <- ls_exposure
    e <- exactextractr::exact_extract(x$raster, sf_geog_geom, fun = "mean")
    dt_e <- data.table::data.table(
      geog_gid,
      year = x$year,
      variable = x$name,
      value = e
    )
    return(dt_e)
  }
  #)
  dt <- data.table::rbindlist(extr)
  
  return(dt)
}

# ls_exposure <- tar_read(tidy_data_exposure)
# str(ls_exposure, max.level = 2)
# sf_geog <- tar_read(tidy_data_geog)
# dt_exp_pop <- tar_read(tidy_data_exp_pop)
