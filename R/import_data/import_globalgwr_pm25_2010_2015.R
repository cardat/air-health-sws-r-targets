#' Construct targets to import and tidy van Donkelaar PM2.5 geographically-weighted regression surfaces rasters
#'
#' @param years A numeric vector of one or more years of interest between 2010-2015. 
#'
#' @return List of targets that tracks the PM2.5 raster files, and reads and tidies the data in target 'tidy_env_exposure' as a RasterBrick.
#' 
#' @examples
#' import_globalgwr_pm25_2010_2015(2013:2014)

import_globalgwr_pm25_2010_2015 <- function(years){
  
  ## Do checks of input argument
  stopifnot("years must be a vector of years within 2010-2015 inclusive" = 
              length(setdiff(years, 2010:2015)) == 0)
  stopifnot("states must be a non-empty vector" = {length(years) != 0})
  
  file <- tar_files_input(
    infile_globalgwr_pm25_2010_2015, 
    file.path(datadir, sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years))
  )
  
  tidy <- tar_target(
    tidy_env_exposure_pm25,
    {
      b <- brick(stack(infile_globalgwr_pm25_2010_2015))
      # retrieve year for layer label
      names(b) <- basename(tar_read(infile_globalgwr_pm25_2010_2015))
      names(b) <- gsub("GlobalGWR_PM25_GL_([0-9]{4})01.*", "\\1", names(b))
      return(b)
    }
  )
  
  list(file = file,
       tidy = tidy
       )
}

# path <- "~/../cloudstor/Shared/Environment_General/Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"
# tidy_exposure(path)


