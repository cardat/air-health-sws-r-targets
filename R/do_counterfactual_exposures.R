#' @param data.table of usual exposure with fields gid (ABS ASGC), year, variable, value
#' @param delta_x a numeric
#' @param mode - treat delta_x as a ratio of counterfactual over baseline, or absolute (positive value indicates decrease)
#'
#' @return data.table of geographic code, year, variable name, counterfactual value

do_counterfactual_exposures <- function(exposure, delta_x, mode = "ratio"){
  if (mode == "abs"){
    exposure[, value := sapply(value-delta_x, max, 0, na.rm = T)] # truncate at 0
  } else if (mode == "ratio"){
    exposure[, value := value * delta_x]
  }
  
  # exposure[, value := NULL]
  
  return(exposure)
  
}
