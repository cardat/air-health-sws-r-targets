do_tidy_study_pop <- function(infile_abs_sa2_pop_age_2016){
  ## read file
  dat <- data.table::fread(infile_abs_sa2_pop_age_2016, colClasses = list(character = c("SA2_MAINCODE_2016")))
  
  ## set column names
  data.table::setnames(dat, names(dat), tolower(names(dat)))
  data.table::setnames(dat, "sa2_maincode_2016", "sa2_main16")
  data.table::setnames(dat, "value", "pop")
  ## get state code
  states_recode <- c("NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT")
  dat[, ste_code16 := substr(sa2_main16, 1, 1)]
  dat[, state := states_recode[as.integer(ste_code16)]]
  
  # subset
  datV2 <- dat[state %in% states]
  
  return(datV2)
}