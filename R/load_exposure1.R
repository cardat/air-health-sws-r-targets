#' @return data.table of geographic code, year, variable name, value

# x_conc <- file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif")
# y_geog <- file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp")

load_exposure_raster <- function(
  inp_r,
  inp_v_geog,
  gid,
  year,
  poll,
  area_code = "MB_CODE11"
  ){
  # load in
  r <- raster(inp_r)
  v <- st_read(inp_v_geog)
  
  # drop empty geometries
  v <- v[!st_is_empty(v$geometry),]
  
  # transform vector to raster projection for extraction
  v <- st_transform(v, st_crs(r))
  e <- exactextractr::exact_extract(r, v, "mean")
  
  dat <- data.table(gid = v[[gid]],
                    year = year,
                    variable = poll,
                    value = e)
  setnames(dat, "gid", area_code)
  
  return(dat)
  
}

load_exposure_csv <- function(
  f_path,
  col_gid,
  col_year,
  col_value,
  poll,
  area_code = "MB_CODE11"
  ) {
  dat <- fread(f_path, colClasses = list(character=c(col_gid)))
  setnames(dat, col_gid, area_code)
  setnames(dat, col_year, "year")
  setnames(dat, col_value, "value")
  dat[, variable := poll]
  
  setcolorder(dat, c(area_code, "year", "variable", "value"))
  
  return(dat)
}


### TODO add aggregation gid (correspondences/allocations)
do_exposure_pop_weighted <- function(
  exposure,
  population,
  gid = "MB_CODE16",
  agg = "STE16"
){
  dat <- merge(exposure, population, by = gid)
  
  if (agg == "STE16"){
    do <- substitute(dat[, agg := substr((gid), 1, 1)],
               list(agg = sym(agg), gid = sym(gid)))
    print(do)
    eval(do)
  }
  
  ## set NAs to minimum pollution concentration
  min_val <- min(dat$value, na.rm = TRUE)
  dat[is.na(value), value := min_val]
  
  dat_agg_long <- dat[,
                      .(value_pw = sum(value * pop, na.rm = T)/
                          sum(pop, na.rm = T),
                        nMB = .N,
                        pop = sum(pop, na.rm = T)),
                      by = c(agg,  
                             "year")]
  
  return(dat_agg_long)
}
