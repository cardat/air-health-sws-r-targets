# Define global variables -------------------------------------------------

## Study coverage ####
years <- 2013:2014
states <- c("WA") # character vector of state abbreviations

## Data location ####

## directory path to folder with required CARDAT data - assumes identical folder hierarchical structure
# specify location of CARDAT data (typically parent directory of Environment_General)
dir_cardat <- "~/CARDAT"
# E.G. ON COESRA dir_cardat <- "~/project_group_data/car"

## Environment General folder of CARDAT
dir_envgen <- file.path(dir_cardat,
                        "Environment_General")