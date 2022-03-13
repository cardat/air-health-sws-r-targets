#' TIdy geographical data
#'
#' @param path A file path to vector of geographical area
#'
#' @return Tidied vector geographical area data
#' 
#' @examples
#' tidy_geog("data/abs_meshblocks.shp")

import_abs_sa2_2016 <- function(states){
  states <- unique(toupper(states))
  
  stopifnot("states must be a vector of at least one state abbreviation" = 
              length(setdiff(states, c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT"))) == 0)
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  file <- tar_files_input(infile_abs_sa2_2016, 
                          file.path(datadir, sprintf("ABS_data/ABS_Census_2016/abs_sa2_2016_data_derived/SA2_2016_%s.shp", states))
  )
  
  tidy <- tar_target(tidy_geom_sa2_2016,
                     {sf_geo <- sf::st_read(infile_abs_sa2_2016)
                     sf_geo <- sf_geo[, c("SA2_MAIN16", "SA2_NAME16", "STE_CODE16")]
                     names(sf_geo) <- tolower(names(sf_geo))
                     return(sf_geo)
                     },
                     pattern = map(infile_abs_sa2_2016))
  
  list(file = file,
       tidy = tidy)
}

# path <- "~/../cloudstor/Shared/Environment_General (2)/ABS_data/ABS_Census_2016/abs_sa2_2016_data_derived/SA2_2016_WA.shp"
# tidy_geog(path)