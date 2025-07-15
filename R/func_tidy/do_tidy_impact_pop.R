do_tidy_impact_pop <- function(infile_abs_mortality_sa2_2006_2016, smooth_yy) {
  states_code <- which(c("NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT") %in% states)
  
  ## read in file
  dat <- data.table::fread(infile_abs_mortality_sa2_2006_2016)
  
  ## take mean over smooth_yy values
  datV2 <- rbindlist(lapply(years, function(yy) {
    dat_window <- dat[ASGS_2011 %in% c(states_code)
                      & Time %in% (yy - smooth_yy + 1):yy
                      & Sex == "Persons"]
    
    dat_mean <- data.table::dcast(dat_window[, .(ste_code16 = ASGS_2011, Sex, Age, Measure, Value)], ste_code16 + Sex + Age ~ Measure, fun = mean)
    dat_mean[, year := yy]
    return(dat_mean)
  }))
  
  ## calculate death rate
  datV2[, rate := Deaths / Population]
  
  ## format
  names(datV2) <- tolower(names(datV2))
  datV2[, ste_code16 := as.character(ste_code16)]
  
  return(datV2)
}