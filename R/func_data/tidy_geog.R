#' TIdy geographical data
#'
#' @param path A file path to vector of geographical area
#'
#' @return Tidied vector geographical area data
#' 
#' @examples
#' tidy_geog("data/abs_meshblocks.shp")

tidy_geog <- function(path){
  sf_geo <- sf::st_read(path)
  sf_geo <- sf_geo[, c("MB_CODE16")]
  names(sf_geo) <- tolower(names(sf_geo))
  return(sf_geo)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp"
# tidy_geog(path)