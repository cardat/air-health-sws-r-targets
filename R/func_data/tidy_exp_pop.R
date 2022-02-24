#' Tidy exposure population data
#'
#' @param path 
#'
#' @return Tidied exposure population data in long format with gid and population columns
#'
#' @examples
#' tidy_exp_pop("data/abs_meshblock_population.csv")

tidy_exp_pop <- function(path){
  dat <- data.table::fread(path, colClasses = list(character = c("MB_CODE_2016")))
  dat <- dat[!is.na(Person) & !is.na(State)]
  dat <- dat[, .(mb_code16 = MB_CODE_2016, pop = Person)]
  return(dat)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"
# tidy_geog(path)


