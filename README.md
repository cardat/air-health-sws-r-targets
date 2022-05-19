## Air-Health Scientific Workflow System based on R targets

An R [targets](https://github.com/ropensci/targets) pipeline for environmental health impact assessment using air pollution as a case study.

This has been developed on R 4.1.2 "Bird Hippie" and RStudio 2021.09.2 "Ghost Orchid". It requires R >= 4.0.0 and access to CARDAT's Environment_General data storage folder on [Cloudstor](https://cloudstor.aarnet.edu.au/).

### Download and unzip 

Download and unzip the [air-health-sws-r-targets](https://github.com/cardat/air-health-sws-r-targets) repository from the `Code` dropdown button. Alternatively, clone the repository via RStudio's `New Project > Version Control` dialogue or Git command line.

### Set parameters

Load the R project and open the `_targets.R` script.

- Edit the global variables `years` and `states` to set the study coverage. The present inputs cover states NSW, VIC, QLD, SA, WA, TAS, NT, ACT and years 2010-2015 inclusive.
- Set `download_data` to TRUE if you wish to download the required data via the [cloudstoR](https://github.com/pdparker/cloudstoR) package.
- Set `dir_cardat` to the parent directory of your mirrored Environment_General directory. (This is the destination of the download if `download_data` is `TRUE`.)

### Run the pipeline

Open the `main.R` script. Follow instructions and hints in comments.

- `renv` should automatically install and activate. Install the packages using `renv::restore()` or try the alternative custom installation function `install_pkgs()` (installs the latest version if library not already available). Installation may take some time.
- If you have set `download_data <- FALSE` in `_targets.R`, uncomment and run the lines at the top of the *Run pipeline* section to authenticate your `cloudstoR` package's access to Cloudstor.
- Visualise the targets with `tar_glimpse()` or `tar_visnetwork()`, or get a table of targets with `tar_manifest()`.
- Run the pipeline with `tar_make()`.

