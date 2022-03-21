write_pipeline_perth <- function(
  states = c("WA"),
  years = 2013:2014,
  # ,
  # cf_scenario = "abs",
  # cf_value = 5,
  # case_definition = "crd",
  # rr = c(),
  # tmrel = 0
  # ,
  # presets = "Perth_2014_2016"
  download_data = TRUE,
  cardat_path = "~/CARDAT"
) {
  
  cardat_envgen <- file.path(cardat_path, "Environment_General")
  
  #### write out _targets.R ####
  tar_helper(
    "_targets.R",
    {
      library(targets)
      library(tarchetypes)
      
      sapply(list.files(pattern="[.]R$", path="R/import_data", full.names=TRUE), source)
      sapply(list.files(pattern="[.]R$", path="R/func_data", full.names=TRUE), source) # functions
      sapply(list.files(pattern="[.]R$", path="R/func_analysis", full.names=TRUE), source)
      sapply(list.files(pattern="[.]R$", path="R/func_viz", full.names=TRUE), source)
      
      # Set target-specific options such as packages.
      tar_option_set(packages = c("sf",
                                  "data.table",
                                  "raster",
                                  "exactextractr",
                                  "ggplot2"))
      
      datadir <- !!cardat_envgen
      download_data <- !!download_data
      
      #### Inputs targets ####
      inputs <- list(
        geog = import_abs_mb_2016(!!states),
        geog_agg = import_abs_sa2_2016(!!states),
        
        exp_pop = import_abs_pop_mb_2016(!!states),
        
        exposure = list(
          import_globalgwr_pm25_2010_2015(!!years),
          import_satlur_no2_2012_2015(!!years)
        ),
        
        impact_pop = import_abs_mortality_sa2_2006_2016(!!states, !!years, smooth_yy = 3),
        
        study_pop = import_abs_sa2_pop_age_2016(!!states)
      )
      
      #### Derivation of data targets ####
      derive_data <- list(
        
        # Extraction of exposure by given geometry
        tar_target(
          data_env_exposure_pm25,
          do_env_exposure(tidy_env_exposure_pm25, tidy_geom_mb_2016, "pm25"),
          pattern = map(tidy_geom_mb_2016)
        ), 
        
        # apply impact rate to study population
        tar_target(
          data_study_pop_health,
          do_study_pop_impact(tidy_study_pop,
                              tidy_impact_pop)
        ),
        
        # Provide counterfactual scenario and calculate delta
        tar_target(
          combined_exposures_pop,
          do_env_counterfactual(data_env_exposure_pm25,
                                "min"),
          pattern = map(data_env_exposure_pm25),
        ),
        
        # apply population weighting to baseline exposure and delta, aggregate to merge with study population
        tar_target(
          data_linked_pop_health_enviro,
          do_linked_pop_health_enviro(data_study_pop_health,
                                      combined_exposures_pop,
                                      tidy_exp_pop)
        )
      )
      
      #### Analysis targets ####
      analysis <- list(
        # construct a function given relative risks and theoretical minimum risk
        tar_target(health_impact_function,
                   do_health_impact_function(
                     case_definition = 'crd',
                     # exposure_response_func = c(1.06, 1.02, 1.08),
                     exposure_response_func = c(1.08, NA, NA),
                     theoretical_minimum_risk = 0
                   )
        ),
        
        # calculate the attributable number
        tar_target(calc_attributable_number,
                   do_attributable_number(
                     hif = health_impact_function,
                     linked_pop_health_enviro = data_linked_pop_health_enviro
                   )
        )
      )

      #### Visualisation targets ####
      viz <- list(
        # create map of attributable number
        tar_target(
          viz_an,
          {
            dat_an <- calc_attributable_number#[year == 2015]# & age == "30 - 34"]
            dat_an <- dat_an[,.(pop_tot = sum(value, na.rm = T),
                                                  expected_tot = sum(expected, na.rm = T),
                                                  attributable = sum(attributable, na.rm = T),
                                                  pm25_cf_pw_sa2 = mean(v1, na.rm = T),
                                                  pm25_pw_sa2 = mean(x, na.rm = T)),
                                                  by = .(sa2_main16, year)]
            sf_an <- tidy_geom_sa2_2016
            sf_an <- merge(sf_an, dat_an)
            viz_map_an(sf_an, "attributable")
          }
        )
      )
      
      list(
        inputs = inputs,
        data = derive_data,
        analysis = analysis,
        viz = viz
      )
      
    }
    )
  
}
