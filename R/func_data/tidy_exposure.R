#' Tidy exposure raster
#'
#' @param path 
#'
#' @return Tidied exposure raster with year and name of pollutant
#'
#' @examples
#' tidy_exposure("data/exposure.tif")

tidy_exposure <- function(path){
  r <- raster(path)
  yy <- sub(".*_(2[0-9]{3})01_.*", "\\1", basename(path))
  yy <- as.integer(yy)
  name <- tolower(sub(".*_(PM25)_.*", "\\1", basename(path)))
  
  return(list(name = name,
              year = yy,
              raster = r
              ))
}

# path <- "~/../cloudstor/Shared/Environment_General/Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"
# tidy_exposure(path)


