#' Construct targets to import and tidy ABS 2016 meshblock shapefile
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#' @param name A string to name the tidied data target.
#' @param download A boolean indicating whether the data should be downloaded from Cloudstor.
#' @param datadir_envgen The path to Environment_General, mirroring the CARDAT Environment_General directory structure. If download is TRUE, CARDAT's data will be mirrored here, else an existing mirror directory should be specified.
#'
#' @return List of targets that tracks the ABS 2016 meshblock file, and reads and tidies the data in target 'tidy_geom_mb_2016', dynamically branched over states.
#' 
#' @examples
#' import_abs_mb_2016(c("NSW", "ACT"))

import_abs_mb_2016 <- function(
  states, 
  name = "tidy_geom_mb_2016",
  download = FALSE,
  datadir_envgen = "~/../Cloudstor/Shared/Environment_General"
){
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              all(states %in% c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT")))
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  if(download){
    file <- tar_target_raw(
      "infile_abs_mb_2016",
      substitute({
        # download metadata
        pths_meta <- file.path(
          basename(datadir_envgen),
          c("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/link to ABS website.txt")
        )
        download_cardat(pths_meta, dirname(datadir_envgen))
        # download data files
        pths_data_files <- expand.grid(states = states, format = c("shp", "shx", "dbf", "prj"))
        pths_data <- file.path(
          basename(datadir_envgen),
          sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_%s.%s",
                  pths_data_files$states, pths_data_files$format)
        )
        file_path <- download_cardat(pths_data, dirname(datadir_envgen))
        file_path <- file_path[endsWith(file_path, ".shp")]
      }, list(datadir_envgen = datadir_envgen))
    )
  } else {
    file <- tar_files_input(
      infile_abs_mb_2016, 
      file.path(datadir_envgen, sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_%s.shp", states))
    )
  }
  
  tidy <- tar_target_raw(
    name,
    substitute({
      # read
      sf_geo <- sf::st_read(infile_abs_mb_2016)
      sf_geo <- sf_geo[, c("MB_CODE16", "SA1_MAIN16", "SA2_MAIN16")]
      
      # standardise geometry attributes
      sf_geo <- st_cast(sf_geo, "MULTIPOLYGON")
      sf_geo <- st_transform(sf_geo, 4283)
      
      names(sf_geo) <- tolower(names(sf_geo))
      return(sf_geo)
    }), 
    pattern = substitute(map(infile_abs_mb_2016)))
  
  list(file = file,
       tidy = tidy)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp"
# tidy_geog(path)