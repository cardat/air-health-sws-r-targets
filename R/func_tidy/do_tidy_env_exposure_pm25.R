do_tidy_env_exposure_pm25 <- function(infile_globalgwr_pm25_2010_2015){
  b <- brick(stack(infile_globalgwr_pm25_2010_2015))
  # retrieve year for layer label
  names(b) <- basename(infile_globalgwr_pm25_2010_2015)
  names(b) <- gsub("GlobalGWR_PM25_GL_([0-9]{4})01.*", "\\1", names(b))
  return(b)
}