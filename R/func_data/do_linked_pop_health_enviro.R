#' Calculate pop-weighted exposure, aggregate and merge with study population data
#'
#' @param dt_study_pop_health A data table of the study population and expected impact by SA2, age group, year.
#' @param dt_env_counterfactual A data table of the environmental exposure (value), counterfactual scenario (cf) and calculated delta, by year and meshblock.
#' @param dt_exp_pop A data table of meshblock population (mb_code16 and pop).
#'
#' @return A data table of dt_study_pop_health with attached population-weighted exposures for baseline (x) and counterfactual (v1) scenarios, by year and SA2.
 
do_linked_pop_health_enviro <- function(
  dt_study_pop_health,
  dt_env_counterfactual,
  dt_exp_pop){
  
  #### population-weighted exposures ####
  dt_expo <- merge(dt_env_counterfactual, dt_exp_pop, by = c("mb_code16"))
  dt_expo_agg <- dt_expo[, .(
    x = sum(value * pop, na.rm = T) / sum(pop, na.rm = T),
    v1 = sum(delta * pop, na.rm = T) / sum(pop, na.rm = T),
    pop = sum(pop, na.rm = T)
    ),
    by = .(sa2_main16, year, variable)]
  # some x and v1 are NaN since 0 pop present
  
  #### merge with population response ####
  dt <- merge(dt_study_pop_health, 
              dt_expo_agg[, .(sa2_main16, year, variable, x, v1)],
              by = c("sa2_main16", "year"))
  
  return(dt)
}

# dt_study_pop_health <- tar_read(data_study_pop_health)
# dt_env_counterfactual <- tar_read(combined_exposures)
# dt_exp_pop <- tar_read(tidy_exp_pop)
