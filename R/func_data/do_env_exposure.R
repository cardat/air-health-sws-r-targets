#' Extract mean exposure for polygon features from raster
#'
#' @param exposure A RasterBrick with layers labelled with associated year.
#' @param sf_geog An sf object of Polygons or MultiPolygons.
#' @param variable A string naming the pollutant, recorded in the output data table.
#'
#' @return A data.table in long format of input geometry attributes, variable (pollutant), year and value (concentration).
#' 
#' @example 
#' do_env_exposure(brick_pm25, sf_abs_meshblock, "pm25")

do_env_exposure <- function(exposure, sf_geog, variable){
  
  # check inputs
  stopifnot("'exposure' must be RasterBrick" = class(exposure) == "RasterBrick")
  stopifnot("Names of exposure RasterBrick must contain 4 digit year" = 
              all(grepl("[0-9]{4}", names(exposure))))
  stopifnot("'sf_geog' must be sf object of Polygon or MultiPolygon geometries" = 
              any(class(sf_geog) == "sf") & all(st_geometry_type(sf_geog) %in% c("POLYGON", "MULTIPOLYGON")))
  
  ## get all non-empty geometry
  sf_geog_geom <- sf_geog[!sf::st_is_empty(sf_geog), ]
  
  ## convert attributes to data.table format
  geog_gid<- data.table::as.data.table(sf_geog_geom)
  geog_gid[, geometry := NULL]
  
  ## do extraction, weighted by fraction of cell covered
  e <- exactextractr::exact_extract(exposure, sf_geog_geom, fun = "mean")
  
  ## construct data table for merged data
  dt <- data.table::data.table(
    geog_gid
  )
  if(!missing(variable)){
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
