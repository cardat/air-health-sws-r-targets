#' @param file path to csv or like
#' @param named vector, names are standardised variables in desired order, vector values are fields as named in raw data
#' 
#' @return data.table of geographic code, year, variable name, value

extract_dt <- function(
  input,
  fields
) {
  dat <- fread(input)
  
  # subset
  dat <- dat[, ..fields]
  
  # rename
  for (i in names(fields)){
    setnames(dat, fields[i], i)
  }
  
  # reorder
  setcolorder(dat, names(fields))
  
  return(dat)
  
}