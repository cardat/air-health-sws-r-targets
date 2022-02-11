#' @param file path to csv or like
#' @param named vector, names are standardised variables in desired order, vector values are fields as named in raw data
#' @param single character string of condition(s) for subsetting by row
#' 
#' @return data.table of geographic code, year, variable name, value

extract_dt <- function(
  input,
  fields,
  subset_conditions = NULL,
  ...
) {
  dat <- fread(input, ...)
  
  # filter (replace with proper substitution)
  if (!is.null(subset_conditions)){
    dat <- dat[eval(parse(text = subset_conditions))]
  }
  
  
  # select columns
  dat <- dat[, ..fields]
  
  # rename
  for (i in names(fields)){
    setnames(dat, fields[i], i)
  }
  # reorder
  setcolorder(dat, names(fields))
  
  return(dat)
  
}