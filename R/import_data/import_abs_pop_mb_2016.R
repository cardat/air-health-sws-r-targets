#' Tidy exposure population data
#'
#' @param path 
#'
#' @return Tidied exposure population data in long format with gid and population columns
#'
#' @examples
#' tidy_exp_pop("data/abs_meshblock_population.csv")

import_abs_pop_mb_2016 <- function(states){
  states <- unique(toupper(states))
  
  stopifnot("states must be a vector of at least one state abbreviation" = 
              length(setdiff(states, c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT"))) == 0)
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  states_code <- car::recode(states, "'NSW'=1; 'VIC'=2; 'QLD'=3; 'SA'=4; 'WA'=5; 'TAS'=6; 'NT'=7; 'ACT'=8")
  
  file <- tar_target(
    infile_abs_mb_pop_2016,
    file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
    format = "file"
  )
  
  tidy <- tar_target_raw("tidy_exp_pop",
                         substitute({dat <- data.table::fread(infile_abs_mb_pop_2016, colClasses = list(character = c("MB_CODE_2016")))
                         dat <- dat[!is.na(Person) & !is.na(State)] # remove footers
                         dat <- dat[State %in% c(states_code)]
                         dat <- dat[, .(mb_code16 = MB_CODE_2016, pop = Person)]
                         
                         return(dat)
                         },list(states_code = states_code))
  )
  
  list(file = file,
       tidy = tidy)
  
}

# infile_pop_abs_mb_2016 <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"
# tidy_geog(path)


