#' Tidy impact population data
#'
#' @param path 
#'
#' @return Tidied data.table in format dt, containing gid, age groups, year, population, death, rate
#'
#' @examples
#' tidy_impact_pop("data/agespecific_year_occurrence.csv")

tidy_impact_pop <- function(path){
  
  dat <- data.table::fread(path)
  
  dat[Region == "Australian Capital Territory", Region := "ACT"]
  dat[Region == "New South Wales", Region := "NSW"]
  dat[Region == "Northern Territory", Region := "NT"]
  dat[Region == "Queensland", Region := "QLD"]
  dat[Region == "South Australia", Region := "SA"]
  dat[Region == "Tasmania", Region := "TAS"]
  dat[Region == "Victoria", Region := "VIC"]
  dat[Region == "Western Australia", Region := "WA"]
  
  datV2 <- dat[Region %in% c("WA")
               & Sex == "Persons"]
  
  datV3 <- data.table::dcast(datV2[, .(ste_code16 = ASGS_2011, Sex, Age, Measure, Time, Value)], 
                             ... ~ Measure, fun = mean)
  
  datV3[, rate := Deaths / Population]
  
  # plot(datV3$rate * 1000, datV3$`Age-specific death rate`)
  
  return(datV3)
}

# path <- "~/../cloudstor/Shared/Environment_General/Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"
# tidy_impact_pop(path)


