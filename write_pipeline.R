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
    input_exposure <- file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif")
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
      
      sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source) # functions
      
      # Set target-specific options such as packages.
      tar_option_set(packages = c("data.table",
                                  "sf",
                                  "raster",
                                  "exactextractr"))
      
      #### Inputs ####
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
            pattern = map(infile_exposure)
          ),
          tar_target(
            tidy_data_exposure,
            rbind(tidy_data_exposure_part)
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
      
      derive_data <- list(
        tar_target(
          data_study_pop_health,
          do_study_pop_impact(tidy_data_study_pop,
                              tidy_data_impact_pop)
        ),
        tar_target(
          data_exposures_pop,
          do_exposures(tidy_data_exposures,
                       tidy_data_geog,
                       tidy_data_exp_pop)
        ),
        tar_target(
          data_counterfactual_pop,
          do_counterfactual_exposures(data_exposures_pop)
        ),
        tar_target(data_linked_pop_health_enviro,
                   merge(data_study_pop_health,
                         data_exposures_pop,
                         data_counterfactual_pop))
      )
      
      
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
      
      viz <- list(
      )
      
      list(
        inputs = inputs,
        data = derive_data,
        analysis = analysis,
        viz = viz,
        !!test
        
      #   # targets_response,
      #   # 
      #   # targets_exposures,
      #   # tarchetypes::tar_combine(
      #   #   all_exposures,
      #   #   targets_exposures$processing$dat_exposure,
      #   #   command = rbind(!!!.x)
      #   # ),
      #   # 
      #   # #### Analysis ####
      #   # tar_target(health_impact_function,
      #   #            do_health_impact_function(
      #   #              case_definition = 'crd',
      #   #              exposure_response_func = c(1.06, 1.02, 1.08),
      #   #              theoretical_minimum_risk = 0
      #   #            )
      #   # ),
      #   
      #   tar_target(dat_linked_pop_health_enviro,
      #              load_linked_pop_health_enviro(
      #                study_pop_health = dat_study_pop_health,
      #                exposures_counterfactual_linked = dat_exposures_counterfactual_linked
      #              )
      #   ),
      #   
      #   tar_target(dat_attributable_number,
      #              do_attributable_number(
      #                hif = health_impact_function,
      #                linked_pop_health_enviro = dat_linked_pop_health_enviro
      #              )
      #   ),
      #   
      #   tar_target(dat_study_pop_health,
      #              do_study_pop_health(
      #                study_population,
      #                standard_pop_health,
      #                "Deaths", "Population"
      #              ),
      #              
      # end
      )
      
    }
    )
  
}
# 
# write_pipeline()
# 
# datadir <- "~/../cloudstor/Shared/Environment_General/"
# params <- list(
#   input_geog = list(
#     file = file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp")
#   ),
#   
#   input_exp = list(
#     file = file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif")
#   ),
#   
#   input_exp_pop = list(
#     file = file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
#     var = list(
#       gid = list(
#         name = "MB_CODE_2016",
#         code = "MB_CODE16"
#       ),
#       pop = list(
#         name = "Person",
#         code = "pop"
#       )
#     )
#   )
# )
# 
# ## geographical geom
# tar_target(exp_geog_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp"), format = "file"),
# 
# ## pollutant concentration
# tar_target(exposure1_raw_f, file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"), format = "file"),
# ## counterfactual
# # ??? numeric/raster/csv/shape
# ## meshblock pops
# tar_target(exp_pop_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"), format = "file"),
# # mb_pops_varlist <- c("MB_CODE16", "MB_CATEGORY_NAME_2016", "Person")
# 
# ## impact
# tar_target(impact_pop_f, file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"), format = "file"),
# # indat_death_varlist <- c("Region", "Sex", "Age", "Measure", "Time", "Value")
# ## baseline pop stats
# tar_target(study_pop_f, file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"), format = "file"),