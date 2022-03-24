#' Construct targets to import and tidy van Donkelaar PM2.5 geographically-weighted regression surfaces rasters
#'
#' @param years A numeric vector of one or more years of interest between 2010-2015. 
#' @param name A string to name the tidied data target.
#' @param download A boolean indicating whether the data should be downloaded from Cloudstor.
#' @param datadir_envgen The path to Environment_General, mirroring the CARDAT Environment_General directory structure. If download is TRUE, CARDAT's data will be mirrored here, else an existing mirror directory should be specified.
#'
#' @return List of targets that tracks the PM2.5 raster files, and reads and tidies the data in target 'tidy_env_exposure' as a RasterBrick.
#' 
#' @examples
#' import_globalgwr_pm25_2010_2015(2013:2014)

import_globalgwr_pm25_2010_2015 <- function(
  years,
  name = "tidy_env_exposure_pm25",
  download = FALSE,
  datadir_envgen = "~/../Cloudstor/Shared/Environment_General"
){
  
  ## Do checks of input argument
  stopifnot("years must be a vector of years within 2010-2015 inclusive" = 
              length(setdiff(years, 2010:2015)) == 0)
  stopifnot("states must be a non-empty vector" = {length(years) != 0})
  
  if(download){
    file <- tar_target_raw(
      "infile_globalgwr_pm25_2010_2015", 
      substitute({
        # download metadata
        pths_meta <- file.path(
          basename(datadir_envgen), 
          c("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/globalgwr_pm25_v4gl02_metadata.pdf")
        )
        download_cardat(pths_meta, dirname(datadir_envgen))
        # download data files
        pths_data <- file.path(
          basename(datadir_envgen), 
          sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years)
        )
        download_cardat(pths_data, dirname(datadir_envgen))
      }, list(datadir_envgen = datadir_envgen))
    )
  } else {
    file <- tar_files_input(
      infile_globalgwr_pm25_2010_2015, 
      file.path(datadir_envgen, sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years))
    )
  }
  
  tidy <- tar_target_raw(
    name,
    substitute({
      b <- brick(stack(infile_globalgwr_pm25_2010_2015))
      # retrieve year for layer label
      names(b) <- basename(tar_read(infile_globalgwr_pm25_2010_2015))
      names(b) <- gsub("GlobalGWR_PM25_GL_([0-9]{4})01.*", "\\1", names(b))
      return(b)
    })
  )
  
  list(file = file,
       tidy = tidy
  )
}

# path <- "~/../cloudstor/Shared/Environment_General/Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"
# tidy_exposure(path)


