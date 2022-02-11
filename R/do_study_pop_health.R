do_study_pop_health <- function(
               study_population,
               standard_pop_health,
               col_health,
               col_pop){
  standard_pop_health[, rate_inc := eval(parse(text = col_health))/eval(parse(text = col_pop))]
  
  ## Replace with correspondence/allocation lookup
  study_population[, STE11 := substr(SA2_MAIN, 1, 1)]
  
  dat <- merge(study_population, standard_pop_health[, .(STE11, age, rate_inc)], by = c("STE11", "age"))
  
  dat[, expected := pop * rate_inc]
  
  return(dat)
  
}
