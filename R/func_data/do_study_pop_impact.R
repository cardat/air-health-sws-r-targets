#' Combine study population and impact statistics to calculate expected incidence
#'
#' @param dt_study A data table of the study population (pop) by SA2, age group and state (variables sa2_main16, age, ste_code16)
#' @param dt_impact A data table of the impact incidence (rate) by state, age group, year (ste_code16, age, year)
#'
#' @return A data table of the study population by SA2, age group, state with attached state incidence rate and consequent expected incidence.

do_study_pop_impact <- function(dt_study, dt_impact){
  data.table::setDT(dt_study) # sa2, pm25_pw, cf_pm25_pw, pop, year
  data.table::setDT(dt_impact) # sa2, age, value, rate, expected, year
  
  ## subset to age groups
  dt_impact <- dt_impact[grepl("[0-9]+ - [0-9]+", age) | age == "100 and over"]
  dt_study <- dt_study[age != "All ages"]
  # remove extraneous variable column, and add an age_start column for sorting
  dt_study[, `:=`(variable = NULL, 
                  age_start = as.integer(gsub("^([0-9]+).*", "\\1", age))
                  )]
  
  ## Join and allow cartesian for the multiple years of impact data to single year population
  dt_study_impact <- merge(dt_study, dt_impact[, .(ste_code16, age, year, rate)], by = c("ste_code16", "age"), all.x = TRUE, allow.cartesian = T)
  
  # calculate expected incidence
  dt_study_impact[, expected := pop*rate]
  
  # format
  setnames(dt_study_impact, "pop", "pop_study")
  dt_study_impact <- dt_study_impact[order(sa2_main16, year, age_start)]
  
  return(dt_study_impact)
}

# dt_study <- tar_read(tidy_study_pop)
# dt_impact <- tar_read(tidy_impact_pop)
