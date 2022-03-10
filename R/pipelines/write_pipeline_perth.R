write_pipeline_perth <- function(
  states = c("TAS", "WA"),
  years = 2013:2014,
  preset = "Perth_2014_2016"
) {
  #### Inbuilt case studies ####
  # if (preset == "Perth_2014_2016"){
  #   datadir <- "~/../cloudstor/Shared/Environment_General/"
  #   input_geog <- data.frame(
  #     state = states,
  #     path = file.path(datadir,
  #                      sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_%s.shp", states))
  #     )
  #   
  #   input_exp_pop <- file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv")
  #       
  #   input_exposure <- data.frame(
  #     year = years,
  #     path = file.path(datadir, 
  #                      sprintf("Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_%s01_%s12-RH35-NoNegs_AUS_20180618.tif", years, years)
  #                      )
  #   )
  #   
  #   input_impact_pop <- file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv")
  #   
  #   input_study_pop <- file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")
  # } else {
  #   stop("No Preset.")
  # }
  
  tar_helper(
    "_targets.R",
    {
      library(targets)
      library(tarchetypes)
      library(data.table)
      
      sapply(list.files(pattern="[.]R$", path="R/import_data", full.names=TRUE), source)
      sapply(list.files(pattern="[.]R$", path="R/func_data", full.names=TRUE), source) # functions
      sapply(list.files(pattern="[.]R$", path="R/func_analysis", full.names=TRUE), source)
      
      # Set target-specific options such as packages.
      tar_option_set(packages = c("data.table",
                                  "sf",
                                  "raster",
                                  "exactextractr"))
      
      datadir <- "~/../cloudstor/Shared/Environment_General (2)"
      
      #### Inputs targets ####
      inputs <- list(
        geog = import_abs_mb_2016(!!states),
        geog_agg = import_abs_sa2_2016(!!states),
        # geog = list(
        #   tar_files_input(
        #     infile_geog,
        #     !!input_geog$path,
        #     format = "file"
        #   ),
        #   tar_target(
        #     tidy_data_geog_part,
        #     tidy_geog(infile_geog),
        #     pattern = map(infile_geog)
        #   )#,
        #   # tar_target(
        #   #   tidy_data_geog,
        #   #   rbind(tidy_data_geog_part)
        #   # )
        # ),
        
        exp_pop = import_abs_pop_mb_2016(!!states),
        # list(
        #   tar_files_input(
        #     infile_exp_pop,
        #     !!input_exp_pop,
        #     format = "file"
        #   ),
        #   tar_target(
        #     tidy_data_exp_pop_part,
        #     tidy_exp_pop(infile_exp_pop),
        #     pattern = map(infile_exp_pop)
        #   ),
        #   tar_target(
        #     tidy_data_exp_pop,
        #     rbind(tidy_data_exp_pop_part)
        #   )
        # ),
        
        exposure = import_globalgwr_pm25_2010_2015(!!years),
        #   list(
        #   tar_files_input(
        #     infile_exposure,
        #     !!input_exposure$path,
        #     format = "file"
        #   ),
        #   tar_target(
        #     tidy_data_exposure_part,
        #     tidy_exposure(infile_exposure),
        #     pattern = map(infile_exposure),
        #     iteration = "list"
        #   )
        # ),
        
        impact_pop = import_abs_mortality_sa2_2006_2016(!!states, !!years),
        # list(
        #   tar_files_input(
        #     infile_impact_pop,
        #     !!input_impact_pop,
        #     format = "file"
        #   ),
        #   tar_target(
        #     tidy_data_impact_pop_part,
        #     tidy_impact_pop(infile_impact_pop),
        #     pattern = map(infile_impact_pop)
        #   ),
        #   tar_target(
        #     tidy_data_impact_pop,
        #     rbind(tidy_data_impact_pop_part)
        #   )
        # ),
        
        study_pop = import_abs_sa2_pop_age_2016(!!states)
        # list(
        #   tar_files_input(
        #     infile_study_pop,
        #     !!input_study_pop,
        #     format = "file"
        #   ),
        #   tar_target(
        #     tidy_data_study_pop_part,
        #     tidy_study_pop(infile_study_pop),
        #     pattern = map(infile_study_pop)
        #   ),
        #   tar_target(
        #     tidy_data_study_pop,
        #     rbind(tidy_data_study_pop_part)
        #   )
        # )
      )
      
      #### Derivation of data targets ####
      derive_data <- list(
        ## Extraction of exposure by given geometry
        tar_target(data_env_exposure,
                   do_env_exposure(tidy_env_exposure, tidy_geom_mb_2016, "pm25"),
                   map(tidy_geom_mb_2016)
                    ),
        tar_target(
          data_study_pop_health,
          do_study_pop_impact(tidy_study_pop,
                              tidy_impact_pop)
        ),
        
        tar_target(
          combined_exposures_pop,
          do_env_counterfactual(data_env_exposure,
                                      "min"),
          pattern = map(data_env_exposure),
        ),
        
        tar_target(
          data_linked_pop_health_enviro,
          do_linked_pop_health_enviro(data_study_pop_health,
                                      combined_exposures_pop,
                                      tidy_exp_pop)
        )
      )
      
      #### Analysis targets ####
      analysis <- list(
        tar_target(health_impact_function,
                   do_health_impact_function(
                     case_definition = 'crd',
                     exposure_response_func = c(1.06, 1.02, 1.08),
                     theoretical_minimum_risk = 0
                   )
        ),
        tar_target(calc_attributable_number,
                   do_attributable_number(
                     hif = health_impact_function,
                     linked_pop_health_enviro = data_linked_pop_health_enviro
                   )
        )
      )
      
      #### Visualisation targets ####
      viz <- list(
        tar_target(make_map_an,
                   {sf <- merge(tidy_geom_sa2_2016, 
                                calc_attributable_number[, .(sa2_main16, state, attributable)])
                   viz_map_an(sf, "attributable")
                   })
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
