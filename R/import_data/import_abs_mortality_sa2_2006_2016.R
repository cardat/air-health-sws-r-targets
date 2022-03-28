#' Construct targets to import and tidy ABS 2006-2016 SA2 Mortality data
#'
#' Creates two targets, the first to track the data file, the second to read and tidy the data. If a smooth_yy argument greater than 1 is specified, measures of mortality are averaged over smooth_yy number of years ending in the year of interest. For example, with a smooth_yy of 3, the measures of mortality for 2016 will be the result of averaging 2014-2016 statistics.
#'
#' @param states A character vector of one or more Australian state or territory abbreviations. 
#' @param years An integer vector of one or more years of interest. 
#' @param smooth_yy An integer value indicating how many years to average over for smoothing. Default is 1 (no smoothing).
#' @param name A string to name the tidied data target.
#' @param download A boolean indicating whether the data should be downloaded from Cloudstor.
#' @param datadir_envgen The path to Environment_General, mirroring the CARDAT Environment_General directory structure. If download is TRUE, CARDAT's data will be mirrored here, else an existing mirror directory should be specified.
#'
#' @return List of targets that tracks the ABS 2006-2016 SA2 Mortality file, and reads and tidies the data in target 'tidy_impact_pop'.
#' 
#' @examples
#' import_abs_mortality_sa2_2006_2016(c("NSW", "ACT"), 2014:2015, smooth_yy = 1)

import_abs_mortality_sa2_2006_2016 <- function(
  states, years, smooth_yy = 1L,
  name = "tidy_impact_pop",
  download = FALSE,
  datadir_envgen = "~/../Cloudstor/Shared/Environment_General"
){
  states <- unique(toupper(states))
  
  ## Do checks of input argument
  stopifnot("states must be a vector of at least one state abbreviation" = 
              all(states %in% c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT")))
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  ## Do checks of input argument years and smooth_yy
  stopifnot("smooth_yy must be a positive non-zero integer" = smooth_yy %% 1 == 0 & smooth_yy > 0)
  stopifnot("All years (including those implicitly required by smooth_yy) must be within 2006-2016" = 
              all(sapply(years, function(x) (x-smooth_yy+1):x) %in% 2006:2016))
  
  states_code <- car::recode(states, "'NSW'=1; 'VIC'=2; 'QLD'=3; 'SA'=4; 'WA'=5; 'TAS'=6; 'NT'=7; 'ACT'=8")
  
  if(download){
    file <- tar_target_raw(
      "infile_abs_mortality_sa2_2006_2016", 
      substitute({
        # download metadata
        pths_meta <- file.path(
          basename(datadir_envgen), 
          c("Australian_Mortality_ABS/ABS_MORT_2006_2016/abs_mort_2006_2016_metadata.pdf",
            "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/33020_README.txt")
        )
        download_cardat(pths_meta, dirname(datadir_envgen))
        # download data files
        pths_data <- file.path(
          basename(datadir_envgen), "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"
        )
        download_cardat(pths_data, dirname(datadir_envgen))
      }, list(datadir_envgen = datadir_envgen))
    )
  } else {
    file <- tar_target_raw(
      "infile_abs_mortality_sa2_2006_2016",
      substitute(file.path(datadir_envgen, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"),
                 list(datadir_envgen = datadir_envgen)),
      format = "file"
    )
  }
  
  tidy <- tar_target_raw(
    name,
    substitute({
      ## read in file
      dat <- data.table::fread(infile_abs_mortality_sa2_2006_2016)
      
      ## take mean over smooth_yy values
      datV2 <- rbindlist(
        lapply(years, function(yy){
          dat_window <- dat[ASGS_2011 %in% c(states_code)
                            & Time %in% (yy-smooth_yy+1):yy
                            & Sex == "Persons"]
          
          dat_mean <- data.table::dcast(dat_window[, .(ste_code16 = ASGS_2011, Sex, Age, Measure, Value)], 
                                        ste_code16 + Sex + Age ~ Measure, fun = mean)
          dat_mean[, year := yy]
          return(dat_mean)
        })
      )
      
      ## calculate death rate
      datV2[, rate := Deaths / Population]
      
      ## format
      names(datV2) <- tolower(names(datV2))
      datV2[, ste_code16 := as.character(ste_code16)]
      
      return(datV2)
    }, list(states_code = states_code, 
            years = years,
            smooth_yy = smooth_yy)
    )
  )
  
  list(file = file,
       tidy = tidy)
  
}

# path <- "~/../cloudstor/Shared/Environment_General/Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"
# tidy_impact_pop(path)


