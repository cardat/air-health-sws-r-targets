#' Construct targets to import and tidy ABS 2016 SA2 population by age data
#' 
#' Produce targets resulting in a data.table of SA2 2016 population by age, with fields variable, sa2_main16, value, age, ste_code16, state.
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#' @param name A string to name the tidied data target.
#' @param download A boolean indicating whether the data should be downloaded from Cloudstor.
#' @param datadir_envgen The path to Environment_General, mirroring the CARDAT Environment_General directory structure. If download is TRUE, CARDAT's data will be mirrored here, else an existing mirror directory should be specified.
#'
#' @return List of targets that tracks the ABS 2016 SA2 population-age data file, and reads and tidies the data in target 'tidy_study_pop'.
#' 
#' @examples
#' import_abs_sa2_pop_age_2016(c("NSW", "ACT"))

import_abs_sa2_pop_age_2016 <- function(
  states,
  name = "tidy_study_pop",
  download = FALSE,
  datadir_envgen = "~/../Cloudstor/Shared/Environment_General"
){
  
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              length(setdiff(states, c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT"))) == 0)
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  if(download){
    file <- tar_target_raw(
      "infile_abs_sa2_pop_age_2016", 
      substitute({
        # download metadata
        pths_meta <- file.path(
          basename(datadir_envgen), 
          c("ABS_data/ABS_Census_2016/abs_census_2016_metadata.pdf")
        )
        download_cardat(pths_meta, dirname(datadir_envgen))
        # download data files
        pths_data <- file.path(
          basename(datadir_envgen), 
          "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")
        download_cardat(pths_data, dirname(datadir_envgen))
      }, list(datadir_envgen = datadir_envgen))
    )
  } else {
    file <- tar_target_raw(
      "infile_abs_sa2_pop_age_2016",
      substitute(file.path(datadir_envgen, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"),
                 list(datadir_envgen = datadir_envgen)),
      format = "file"
    )
  }
  
  tidy <- tar_target_raw(
    name,
    substitute({
      ## read file
      dat <- data.table::fread(infile_abs_sa2_pop_age_2016, colClasses = list(character = c("SA2_MAINCODE_2016")))
      
      ## set column names
      data.table::setnames(dat, names(dat), tolower(names(dat)))
      data.table::setnames(dat, "sa2_maincode_2016", "sa2_main16")
      data.table::setnames(dat, "value", "pop")
      ## get state code
      states_recode <- c("NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT")
      dat[, ste_code16 := substr(sa2_main16, 1, 1)]
      dat[, state := states_recode[as.integer(ste_code16)]]
      
      # subset
      datV2 <- dat[state %in% states]
      
      return(datV2)
    }, list(states = states)
    )
  )
  
  list(file = file,
       tidy = tidy)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"
# tidy_study_pop(path)


