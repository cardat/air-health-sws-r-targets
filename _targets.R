library(targets)
library(tarchetypes)
library(data.table)
sapply(list.files(pattern = "[.]R$", path = "R/import_data", 
    full.names = TRUE), source)
sapply(list.files(pattern = "[.]R$", path = "R/func_data", full.names = TRUE), 
    source)
sapply(list.files(pattern = "[.]R$", path = "R/func_analysis", 
    full.names = TRUE), source)
tar_option_set(packages = c("data.table", "sf", "raster", "exactextractr"))
inputs <- list(geog = import_abs_mb_2016(c("TAS", "WA")), exp_pop = import_abs_pop_mb_2016(c("TAS", 
"WA")), exposure = import_globalgwr_pm25_2010_2015(2013:2014), 
    impact_pop = import_abs_mortality_sa2_2006_2016(c("TAS", 
    "WA")), study_pop = import_abs_sa2_pop_age_2016(c("TAS", 
    "WA")))
derive_data <- list(tar_target(data_env_exposure, do_env_exposure(tidy_env_exposure, 
    tidy_geometry, "pm25"), map(tidy_geometry)), tar_target(data_study_pop_health, 
    do_study_pop_impact(tidy_study_pop, tidy_impact_pop)), tar_target(combined_exposures_pop, 
    do_env_counterfactual(data_env_exposure, "min"), pattern = map(data_env_exposure), 
    ), tar_target(data_linked_pop_health_enviro, do_linked_pop_health_enviro(data_study_pop_health, 
    combined_exposures_pop, tidy_exp_pop)))
analysis <- list(tar_target(health_impact_function, do_health_impact_function(case_definition = "crd", 
    exposure_response_func = c(1.06, 1.02, 1.08), theoretical_minimum_risk = 0)), 
    tar_target(ana_attributable_number, do_attributable_number(hif = health_impact_function, 
        linked_pop_health_enviro = data_linked_pop_health_enviro)))
viz <- list()
list(inputs = inputs, data = derive_data, analysis = analysis, 
    viz = viz)
