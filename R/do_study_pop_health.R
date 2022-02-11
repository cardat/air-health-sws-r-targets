do_study_pop_health <- function(
               study_population,
               standard_pop_health,
               col_health,
               col_pop){
  eval(substitute(
    standard_pop_health[, rate_inc := var1/var2], 
    env = list(var1 = as.name(col_health), var2 = as.name(col_pop))
    ))
  
  ## Replace with correspondence/allocation lookup
  study_population[, STE11 := substr(SA2_MAIN, 1, 1)]
  print(study_population)
  print(standard_pop_health)
  
  dat <- merge(study_population, standard_pop_health[, .(STE11, age, rate_inc)], by = c("STE11", "age"))
  
  dat[, expected := pop * rate_inc]
  
  return(dat)
  
}
