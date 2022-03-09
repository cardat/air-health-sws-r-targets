write_pipeline <- function(
  input_geog,
  input_exp_pop,
  input_exposure,
  input_impact_pop,
  input_study_pop,
  preset = "Perth_2014_2016"
) {
  #### Inbuilt case studies ####
  if (preset == "Perth_2014_2016"){
    datadir <- "~/../cloudstor/Shared/Environment_General/"
    input_geog <- file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp")
    input_exp_pop <- file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv")
    input_exposure <- c(file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"),
                        file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201401_201412-RH35-NoNegs_AUS_20180618.tif"))
    input_impact_pop <- file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv")
    input_study_pop <- file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")
  } else {
    stop("No Preset.")
  }
  
  test <- bquote(tar_target(trythis, 1+2+3+4))
  
  tar_helper(
    "_targets.R",
    {
      library(targets)
      library(tarchetypes)
      library(data.table)
      
      sapply(list.files(pattern="[.]R$", path="R/func_data", full.names=TRUE), source) # functions
      sapply(list.files(pattern="[.]R$", path="R/func_analysis", full.names=TRUE), source)
      sapply(list.files(pattern="[.]R$", path="R/func_data", full.names=TRUE), source)
      
      # Set target-specific options such as packages.
      tar_option_set(packages = c("data.table",
                                  "sf",
                                  "raster",
                                  "exactextractr"))
      
      #### Inputs targets ####
      inputs <- list(
        geog = list(
          tar_files(
            infile_geog,
            !!input_geog,
            format = "file"
          ),
          tar_target(
            tidy_data_geog_part,
            tidy_geog(infile_geog),
            pattern = map(infile_geog)
          ),
          tar_target(
            tidy_data_geog,
            rbind(tidy_data_geog_part)
          )
        ),
        
        exp_pop = list(
          tar_files(
            infile_exp_pop,
            !!input_exp_pop,
            format = "file"
          ),
          tar_target(
            tidy_data_exp_pop_part,
            tidy_exp_pop(infile_exp_pop),
            pattern = map(infile_exp_pop)
          ),
          tar_target(
            tidy_data_exp_pop,
            rbind(tidy_data_exp_pop_part)
          )
        ),
        
        exposure = list(
          tar_files(
            infile_exposure,
            !!input_exposure,
            format = "file"
          ),
          tar_target(
            tidy_data_exposure_part,
            tidy_exposure(infile_exposure),
            pattern = map(infile_exposure),
            iteration = "list"
          )
        ),
        
        impact_pop = list(
          tar_files(
            infile_impact_pop,
            !!input_impact_pop,
            format = "file"
          ),
          tar_target(
            tidy_data_impact_pop_part,
            tidy_impact_pop(infile_impact_pop),
            pattern = map(infile_impact_pop)
          ),
          tar_target(
            tidy_data_impact_pop,
            rbind(tidy_data_impact_pop_part)
          )
        ),
        
        study_pop = list(
          tar_files(
            infile_study_pop,
            !!input_study_pop,
            format = "file"
          ),
          tar_target(
            tidy_data_study_pop_part,
            tidy_study_pop(infile_study_pop),
            pattern = map(infile_study_pop)
          ),
          tar_target(
            tidy_data_study_pop,
            rbind(tidy_data_study_pop_part)
          )
        )
      )
      
      #### Derivation of data targets ####
      derive_data <- list(
        tar_target(
          data_study_pop_health,
          do_study_pop_impact(tidy_data_study_pop,
                              tidy_data_impact_pop)
        ),
        tar_target(
          data_env_exposure,
          do_env_exposure(tidy_data_exposure_part,
                           tidy_data_geog),
          pattern = map(tidy_data_exposure_part), iteration = "list"
        ),
        tar_target(
          data_env_counterfactual,
          do_env_counterfactual(data_env_exposure,
                                      "min"),
          pattern = map(data_env_exposure), iteration = "list"
        ),
        tar_target(combined_exposures_pop, rbindlist(data_env_counterfactual)),
        tar_target(data_linked_pop_health_enviro,
                   do_linked_pop_health_enviro(
                     data_study_pop_health,
                     combined_exposures_pop,
                     tidy_data_exp_pop)
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
        tar_target(ana_attributable_number,
                   do_attributable_number(
                     hif = health_impact_function,
                     linked_pop_health_enviro = data_linked_pop_health_enviro
                   )
        )
      )
      
      #### Visualisation targets ####
      viz <- list(
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
