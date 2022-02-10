library(targets)
library(tarchetypes)

# source globals
datadir <- "~/../cloudstor/Shared/Environment_General/"
sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source)

# Set target-specific options such as packages.
tar_option_set(packages = c("data.table",
                            "sf",
                            "raster",
                            "exactextractr"))

list(
#### Inputs ####
## geographical geom
tar_target(exp_geog_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp"), format = "file"),

## pollutant concentration
tar_target(exposure1_raw_f, file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif"), format = "file"),
## counterfactual
# ??? numeric/raster/csv/shape
## meshblock pops
tar_target(exp_pop_raw_f, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"), format = "file"),
# mb_pops_varlist <- c("MB_CODE16", "MB_CATEGORY_NAME_2016", "Person")

## impact
tar_target(impact_pop_f, file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"), format = "file"),
# indat_death_varlist <- c("Region", "Sex", "Age", "Measure", "Time", "Value")
## baseline pop stats
tar_target(study_pop_f, file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv"), format = "file"),

#### Load data ####
tar_target(exp_geog_raw, st_read(exp_geog_raw_f)),
tar_target(exposure1_raw, raster(exposure1_raw_f)),
tar_target(data_exp_pop, 
           extract_dt(exp_pop_raw_f,
                      c("MB_CODE11" = "Mesh_Block_ID",
                        "pop" = "Persons_Usually_Resident")
           )
),

tar_target(impact_pop, fread(impact_pop_f)),
tar_target(study_pop, fread(study_pop_f)),


#### Analysis ####
tar_target(health_impact_function,
           do_health_impact_function(
             case_definition = 'crd',
             exposure_response_func = c(1.06, 1.02, 1.08),
             theoretical_minimum_risk = 0
           )
           ),

tar_target(dat_linked_pop_health_enviro,
             load_linked_pop_health_enviro(
               study_pop_health = dat_study_pop_health,
               exposures_counterfactual_linked = dat_exposures_counterfactual_linked
             )
             ),

tar_target(dat_exposure1_prep, {
  if (endsWith(exposure1_raw_f, ".tif") & endsWith(exp_geog_raw_f, ".shp")){
    load_exposure_raster(
      exposure1_raw_f,
      exp_geog_raw_f,
      "MB_CODE11",
      2015,
      "pm25",
      "MB_CODE11"
    )
  } else if (endsWirth(exposure1_raw_f, ".csv")) {
    load_exposure_csv(
      exposure1_raw_f,
      col_gid,
      col_year,
      col_value,
      poll,
      area_code
    )
  }
}
),

tar_target(dat_counterfactual_exposures,
           do_counterfactual_exposures(
             delta_x
           )
         ),

tar_target(dat_exposures_counterfactual_linked,
           do_exposures_counterfactual_linked(
             exposure1_prep = dat_exposure1_prep,
             counterfactual_exposures = dat_counterfactual_exposures
           )
          ),

tar_target(dat_attributable_number,
           do_attributable_number(
             hif = health_impact_function,
             linked_pop_health_enviro = dat_linked_pop_health_enviro
           )
           ),

tar_target(dat_study_pop_health,
           do_study_pop_health(
             study_population,
             standard_pop_health
           )
          )

# end
)
