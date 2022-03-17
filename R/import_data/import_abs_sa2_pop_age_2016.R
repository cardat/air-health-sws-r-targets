#' Construct targets to import and tidy ABS 2016 SA2 population by age data
#' 
#' Produce targets resulting in a data.table of SA2 2016 population by age, with fields variable, sa2_main16, value, age, ste_code16, state.
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#'
#' @return List of targets that tracks the ABS 2016 SA2 population-age data file, and reads and tidies the data in target 'tidy_study_pop'.
#' 
#' @examples
#' import_abs_sa2_pop_age_2016(c("NSW", "ACT"))

import_abs_sa2_pop_age_2016 <- function(states){
  
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              length(setdiff(states, c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT"))) == 0)
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  states_code <- car::recode(states, "'NSW'=1; 'VIC'=2; 'QLD'=3; 'SA'=4; 'WA'=5; 'TAS'=6; 'NT'=7; 'ACT'=8")
  
  file <- tar_target(
    infile_abs_sa2_pop_age_2016,
    file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"),
    format = "file"
  )
  
  tidy <- tar_target_raw(
    "tidy_study_pop",
    substitute({
      ## read file
      dat <- data.table::fread(infile_abs_sa2_pop_age_2016, colClasses = list(character = c("SA2_MAINCODE_2016")))
      
      ## set column names
      data.table::setnames(dat, names(dat), tolower(names(dat)))
      data.table::setnames(dat, "sa2_maincode_2016", "sa2_main16")
      ## get state code
      dat[, ste_code16 := as.integer(substr(sa2_main16, 1, 1))]
      dat[, state := car::recode(
        ste_code16,
        "'1'='NSW'; '2'='VIC'; '3'='QLD'; '4'='SA'; '5'='WA'; '6'='TAS'; '7'='NT';'8'='ACT'; '9' = 'OT'"                          
      )]
      
      # subset
      datV2 <- dat[ste_code16 %in% c(states_code)]
      
      return(datV2)
    }, list(states_code = states_code)
    )
  )
  
  list(file = file,
       tidy = tidy)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"
# tidy_study_pop(path)


