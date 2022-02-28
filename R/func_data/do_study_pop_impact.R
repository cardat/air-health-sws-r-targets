do_study_pop_impact <- function(dt_study, dt_impact){
  data.table::setDT(dt_study)
  data.table::setDT(dt_impact)
  
  ## 
  dt_study <- dt_study[age != "All ages"]
  dt_study_impact <- merge(dt_study, dt_impact[, .(ste_code16, age, rate)], by = c("ste_code16", "age"), all.x = TRUE)
  dt_study_impact[, expected := value*rate]
  
  return(dt_study_impact)
}

# dt_study <- tar_read(tidy_data_study_pop)
# dt_impact <- tar_read(tidy_data_impact_pop)
