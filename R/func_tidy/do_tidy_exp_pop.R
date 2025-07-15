do_tidy_exp_pop <- function(infile_abs_mb_pop_2016){
  states_code <- which(c("NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT") %in% states)
  
  dat <- data.table::fread(infile_abs_mb_pop_2016, colClasses = list(character = c("MB_CODE_2016")))
  dat <- dat[!is.na(Person) & !is.na(State)] # remove footers
  dat <- dat[State %in% c(states_code)]
  dat <- dat[, .(mb_code16 = MB_CODE_2016, pop = Person)]

  return(dat)
}