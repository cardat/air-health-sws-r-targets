#' Tidy study population data
#'
#' @param path 
#'
#' @return Tidied data.table in format dt, containing gid, age groups, year, population
#'
#' @examples
#' tidy_study_pop("data/study_pop.csv")

tidy_study_pop <- function(path){
  
  dat <- data.table::fread(path, colClasses = list(character = c("SA2_MAINCODE_2016")))
  data.table::setnames(dat, names(dat), tolower(names(dat)))
  
  data.table::setnames(dat, "sa2_maincode_2016", "sa2_main16")
  dat[, ste_code16 := as.integer(substr(sa2_main16, 1, 1))]
  dat[, state := car::recode(ste_code16,
                            "'1'='NSW'; '2'='VIC'; '3'='QLD'; '4'='SA'; '5'='WA'; '6'='TAS'; '7'='NT';'8'='ACT'; '9' = 'OT'"                          
  )]
  
  datV2 <- dat[state == "WA"]
  
  return(datV2)
}

# path <- "~/../cloudstor/Shared/Environment_General/ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"
# tidy_study_pop(path)


