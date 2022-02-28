#' @param data.table of usual exposure with fields gid (ABS ASGC), year, variable, value
#' @param delta_x a numeric
#' @param mode - treat delta_x as a ratio of counterfactual over baseline, or absolute (positive value indicates decrease)
#'
#' @return data.table of geographic code, year, variable name, counterfactual value

do_counterfactual_exposures_linked <- function(exposure_baseline, exposure_counterfactual){
  
}
