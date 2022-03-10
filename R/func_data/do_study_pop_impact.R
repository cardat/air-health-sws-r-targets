do_study_pop_impact <- function(dt_study, dt_impact){
  data.table::setDT(dt_study) # sa2, pm25_pw, cf_pm25_pw, pop, year
  data.table::setDT(dt_impact) # sa2, age, value, rate, expected, year
  
  ## 
  dt_impact <- dt_impact[grepl("[0-9]+ - [0-9]+", age) | age == "100 and over"]
  dt_study <- dt_study[age != "All ages"]
  ## Join and allow cartesian for the multiple years of impact data to single year population
  dt_study_impact <- merge(dt_study, dt_impact[, .(ste_code16, age, year, rate)], by = c("ste_code16", "age"), all.x = TRUE, allow.cartesian = T)
  dt_study_impact[, expected := value*rate]
  
  return(dt_study_impact)
}

# dt_study <- tar_read(tidy_study_pop)
# dt_impact <- tar_read(tidy_impact_pop)
