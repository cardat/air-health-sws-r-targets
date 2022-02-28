do_linked_pop_health_enviro <- function(
  dt_study_pop_health,
  dt_env_counterfactual,
  dt_exp_pop){
  
  #### population-weighted exposures ####
  dt_expo <- merge(dt_env_counterfactual, dt_exp_pop)
  dt_expo_agg <- dt_expo[, .(x = sum(value * pop, na.rm = T)/sum(pop, na.rm = T),
            v1 = sum(value_cf_red * pop, na.rm = T)/sum(pop, na.rm = T),
            pop = sum(pop, na.rm = T)),
     by = .(sa2_main16, year, variable)]
  
  #### merge with population response ####
  dt_expo_agg <- dt_expo_agg[, .(x = mean(x), v1 = mean(v1)), by= .(sa2_main16, variable)]
  dt <- merge(dt_study_pop_health, dt_expo_agg[, .(sa2_main16, variable, x, v1)], by = c("sa2_main16"))
  
  return(dt)
}

# dt_study_pop_health <- tar_read(data_study_pop_health)
# dt_env_counterfactual <- tar_read(combined_exposures_pop)
# dt_exp_pop <- tar_read(tidy_data_exp_pop)
