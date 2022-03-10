#' Tidy impact population data
#'
#' @param path 
#'
#' @return Tidied data.table in format dt, containing gid, age groups, year, population, death, rate
#'
#' @examples
#' tidy_impact_pop("data/agespecific_year_occurrence.csv")

import_abs_mortality_sa2_2006_2016 <- function(states, years, smooth_yy = 3){
  states <- unique(toupper(states))
  
  stopifnot("states must be a vector of at least one state abbreviation" = 
              length(setdiff(states, c("NSW", "VIC", "QLD", "SA", "TAS", "WA", "NT", "ACT"))) == 0)
  stopifnot("states must be a non-empty vector" = {length(states) != 0})
  
  states_code <- car::recode(states, "'NSW'=1; 'VIC'=2; 'QLD'=3; 'SA'=4; 'WA'=5; 'TAS'=6; 'NT'=7; 'ACT'=8")
  
  file <- tar_target(
    infile_abs_mortality_sa2_2006_2016,
    file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"),
    format = "file"
  )
  
  tidy <- tar_target_raw(
    "tidy_impact_pop",
    substitute({
      dat <- data.table::fread(infile_abs_mortality_sa2_2006_2016)
      
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
      
      datV2[, rate := Deaths / Population]
      
      names(datV2) <- tolower(names(datV2))
      
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


