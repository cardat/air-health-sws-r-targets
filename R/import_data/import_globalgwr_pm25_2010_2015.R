#' Tidy exposure raster
#'
#' @param path 
#'
#' @return Tidied exposure raster with year and name of pollutant
#'
#' @examples
#' tidy_exposure("data/exposure.tif")

import_globalgwr_pm25_2010_2015 <- function(years){
  
  stopifnot("years must be a vector of years within 2010-2015 inclusive" = 
              length(setdiff(years, 2010:2015)) == 0)
  stopifnot("states must be a non-empty vector" = {length(years) != 0})
  
  file <- tar_files_input_raw(
    "infile_globalgwr_pm25_2010_2015", 
    file.path(datadir, sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years)))
  
  tidy <- tar_target_raw("tidy_env_exposure",
                         substitute({
                           b <- brick(stack(infile_globalgwr_pm25_2010_2015))
                           names(b) <- years
                           return(b)
                         }))
  
  list(file = file,
       tidy = tidy
       )
}

# path <- "~/../cloudstor/Shared/Environment_General/Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"
# tidy_exposure(path)


