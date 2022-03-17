#' Construct targets to import and tidy ABS 2016 meshblock shapefile
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#'
#' @return List of targets that tracks the ABS 2016 meshblock file, and reads and tidies the data in target 'tidy_geom_mb_2016', dynamically branched over states.
#' 
#' @examples
#' import_abs_mb_2016(c("NSW", "ACT"))

import_abs_mb_2016 <- function(states){
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              all(states %in% c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT")))
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  file <- tar_files_input(
    infile_abs_mb_2016, 
    file.path(datadir, sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_%s.shp", states))
  )
  
  tidy <- tar_target(
    tidy_geom_mb_2016,
    {
      # read
      sf_geo <- sf::st_read(infile_abs_mb_2016)
      sf_geo <- sf_geo[, c("MB_CODE16", "SA1_MAIN16", "SA2_MAIN16")]
      
      # standardise geometry attributes
      sf_geo <- st_cast(sf_geo, "MULTIPOLYGON")
      sf_geo <- st_transform(sf_geo, 4283)
      
      names(sf_geo) <- tolower(names(sf_geo))
      return(sf_geo)
    }, 
    pattern = map(infile_abs_mb_2016))
  
  list(file = file,
       tidy = tidy)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp"
# tidy_geog(path)