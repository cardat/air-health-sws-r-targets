#### INPUTS ####

datadir <- "~/../cloudstor/Shared/Environment_General"

#### Pollutant(s) ####
indir_poll <- file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/")
# dir(indir_expo)

input_poll <- rbindlist(
  list(
    list(
      name = "pm25",
      path = file.path(indir_poll, "GlobalGWR_PM25_GL_201001_201012-RH35-NoNegs_AUS_20180618.tif"),
      year = 2010),
    list(
      name = "pm25",
      path = file.path(indir_poll, "GlobalGWR_PM25_GL_201201_201212-RH35-NoNegs_AUS_20180618.tif"),
      year = 2015)
  )
)

#### Exposures population ####
sel_expo_abs <- "MB_CODE16"

input_expo_pop <- switch(sel_expo_abs,
                   "MB_CODE16" = list(
                     path = file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv"),
                     vars = c(
                       gid = "MB_CODE16", # required
                       pop = "Person", # required
                       category = "MB_CATEGORY_NAME_2016"
                     )
                   )
)

input_expo_pop_shp <- switch(sel_expo_abs,
                         "MB_CODE16" = list(
                           path = file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp")
                         )
)

#### Response ####
sel_response <- "ABS_Mortality"

input_response <- switch(sel_response,
                         "ABS_Mortality" = list(
                           path = file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv")
                           )
)


#### Sample population ####
sel_sample <- "SA2_2016"

input_sample_pop <- list(
  path = file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived/abs_sa2_2016_agecatsV2_total_persons_20180405.csv")
)


#### Correspondences/allocations ####
# input_geo_corr <- list()


# 
# ##mb
# indir_mb <- file.path(datadir,  sprintf("ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided"))
# infile_mb <- sprintf("MB_2016_%s", state)
# ## meshblock pops
# indir_mb_pops <- file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided")
# dir(indir_mb_pops)
# infile_mb_pops <- "2016 census mesh block counts.csv"
# mb_pops_varlist <- c("MB_CODE16", "MB_CATEGORY_NAME_2016", "Person")
# 
# ## pops at sa2
# indir_pop <- file.path(datadir, "ABS_data/ABS_Census_2016/abs_gcp_2016_data_derived")
# infile_pop_sa2 <- "abs_sa2_2016_agecatsV2_total_persons_20180405.csv"
# 
# ## 0301 load health rates standard
# ## TODO if age specific use
# indir_death <- file.path(datadir, "Australian_Mortality_ABS/ABS_MORT_2006_2016/data_provided/")
# infile_death <- "DEATHS_AGESPECIFIC_OCCURENCEYEAR_04042018231304281.csv"
# indat_death_varlist <- c("Region", "Sex", "Age", "Measure", "Time", "Value")
# 
# ## if cause specific use
# ## the aihw mort books
# 
# ## exposure
# indir_expo <- file.path(datadir, "Air_pollution_model_GlobalGWR_PM25/GlobalGWR_PM25_V4GL02/data_derived/")
# 
# 
# indir_sa3 <- file.path(datadir, "ABS_data/ABS_Census_2016/abs_sa3_2016_data_provided")
# infile_sa3 <- "SA3_2016_AUST"
