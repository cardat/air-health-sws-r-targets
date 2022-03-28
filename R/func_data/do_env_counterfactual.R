#' Calculate a counterfactual concentration and consequent delta compared to baseline
#'
#' A "min" counterfactual sets the counterfactual exposure to be the minimum concentration by state. A "abs" counterfactual sets the counterfactual exposure to the supplied value, except where the baseline concentration is already below the counterfactual - in this case the counterfactual is set equal to baseline.
#'
#' @param dt_exposure A data table of the exposure concentration (value) by meshblock, state and year (mb_code16, ste_code16, year)
#' @param cf_mode A string indicating what calculation to use for the counterfactual - "min" for minimum by state, "abs" for an absolute concentration
#' @param cf_value If cf_mode == "abs", a numeric value to set as the counterfactual concentration
#'
#' @return A copy of dt_exposure with attached counterfactual concentration and calculated delta.

do_env_counterfactual <- function(dt_exposure, 
                                  cf_mode = "abs",
                                  cf_value){
  
  ## set counterfactual to minimum by state
  if(cf_mode == "min"){ 
    cf_value <- dt_exposure[, .(cf = min(value, na.rm = T)), by = ste_code16]
    dt_exposure <- merge(dt_exposure, cf_value)
  
  ## set counterfactual to supplied value
  } else if (cf_mode == "abs") {
    stopifnot("Missing a counterfactual absolute value in 'abs' mode" = !missing(cf_value))
    dt_exposure[, cf := cf_value]
    # except where supplied value is higher than baseline value
    dt_exposure[cf > value, cf := value]
  }
  # calculate delta
  dt_exposure[, delta := (value - cf)]
  
  return(dt_exposure)
}

# dt_exposure <- tar_read(data_env_exposure_pm25)
