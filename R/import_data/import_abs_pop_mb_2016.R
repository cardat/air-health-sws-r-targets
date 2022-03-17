#' Construct targets to import and tidy ABS 2016 meshblock population csv file
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#'
#' @return List of targets that tracks the ABS 2016 meshblock population csv file, and reads and tidies the data in target 'tidy_exp_pop'.
#' 
#' @examples
#' import_abs_pop_mb_2016(c("NSW", "ACT"))

import_abs_pop_mb_2016 <- function(states){
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              all(states %in% c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT")))
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  states_code <- car::recode(states, "'NSW'=1; 'VIC'=2; 'QLD'=3; 'SA'=4; 'WA'=5; 'TAS'=6; 'NT'=7; 'ACT'=8")
  
  file <- tar_target(
    infile_abs_mb_pop_2016,
    file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
    format = "file"
  )
  
  tidy <- tar_target_raw(
    "tidy_exp_pop",
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
# import_abs_pop_mb_2016("NSW")


