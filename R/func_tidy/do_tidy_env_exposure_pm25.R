do_tidy_env_exposure_pm25 <- function(infile_globalgwr_pm25_2010_2015){
  s <- terra::rast(infile_globalgwr_pm25_2010_2015)
  # retrieve year for layer label
  yy <- basename(infile_globalgwr_pm25_2010_2015)
  yy <- as.integer(gsub("GlobalGWR_PM25_GL_([0-9]{4})01.*", "\\1", yy))
  names(s) <- yy
  time(s) <- yy
  return(wrap(s))
}