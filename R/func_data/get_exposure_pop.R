get_exposures_mb2016 <- function(){
  list(
    tar_target(infile_geog, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_data_provided/MB_2016_WA.shp")),
    tar_target(tidy_expo_geog, st_read(infile_geog)),
    
    tar_target(infile_expo_abs, file.path(datadir, "ABS_data/ABS_meshblocks/abs_meshblocks_2016_pops_data_provided/2016 census mesh block counts.csv", format = "file")),
    tar_target(tidy_expo_abs, {
      dat <- fread(input_expo_abs, colClasses = list(character = c("MB_CODE_2016")))
      extract_dt(
        dat,
        c("MB_CODE16" = "MB_CODE_2016",
          "pop" = "Person")
      )
    })
  )
}