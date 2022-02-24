library(targets)
library(tarchetypes)
library(data.table)
sapply(list.files(pattern = "[.]R$", path = "R/", full.names = TRUE), 
    source)
tar_option_set(packages = c("rlang", "data.table", "sf", "raster", 
    "exactextractr"))
inputs <- list(geog = list(tar_files(infile_geog, "~/../cloudstor/Shared/Environment_General//ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_VIC.shp", 
    format = "file"), tar_target(tidy_data_geog_part, tidy_geog(infile_geog), 
    pattern = map(infile_geog)), tar_target(tidy_data_geog, rbind(tidy_data_geog_part))), 
    exp_pop = list(tar_files(infile_exp_pop, "~/../cloudstor/Shared/Environment_General//ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv", 
        format = "file"), tar_target(tidy_data_exp_pop_part, 
        tidy_exp_pop(infile_exp_pop), pattern = map(infile_exp_pop)), 
        tar_target(tidy_data_exp_pop, rbind(tidy_data_exp_pop_part))), 
    exposure = list(tar_files(infile_exposure, "~/../cloudstor/Shared/Environment_General//Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/GlobalGWR_PM25_GL_201501_201512-RH35-NoNegs_AUS_20180618.tif", 
        format = "file"), tar_target(tidy_data_exposure_part, 
        tidy_exposure(infile_exposure), pattern = map(infile_exposure)), 
        tar_target(tidy_data_exposure, rbind(tidy_data_exposure_part))), 
    impact_pop = list(tar_files(infile_impact_pop, "~/../cloudstor/Shared/Environment_General//Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv", 
        format = "file"), tar_target(tidy_data_impact_pop_part, 
        tidy_impact_pop(infile_impact_pop), pattern = map(infile_impact_pop)), 
        tar_target(tidy_data_impact_pop, rbind(tidy_data_impact_pop_part))), 
    study_pop = list(tar_files(infile_study_pop, "~/../cloudstor/Shared/Environment_General//ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv", 
        format = "file"), tar_target(tidy_data_study_pop_part, 
        tidy_study_pop(infile_study_pop), pattern = map(infile_study_pop)), 
        tar_target(tidy_data_study_pop, rbind(tidy_data_study_pop_part))))
derive_data <- list(tar_target(data_study_pop_health, do_study_pop_impact(tidy_data_study_pop, 
    tidy_data_impact_pop)), tar_target(data_exposures_pop, do_exposures(tidy_data_exposures, 
    tidy_data_geog, tidy_data_exp_pop)), tar_target(data_counterfactual_pop, 
    do_counterfactual_exposures(data_exposures_pop)), tar_target(data_linked_pop_health_enviro, 
    merge(data_study_pop_health, data_exposures_pop, data_counterfactual_pop)))
analysis <- list(tar_target(health_impact_function, do_health_impact_function(case_definition = "crd", 
    exposure_response_func = c(1.06, 1.02, 1.08), theoretical_minimum_risk = 0)), 
    tar_target(dat_attributable_number, do_attributable_number(hif = health_impact_function, 
        linked_pop_health_enviro = data_linked_pop_health_enviro)))
viz <- list()
list(inputs = inputs, data = derive_data, analysis = analysis, 
    viz = viz, tar_target(trythis, 1 + 2 + 3 + 4))
