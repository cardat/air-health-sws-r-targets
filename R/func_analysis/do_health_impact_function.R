#' Construct a health impact function to calculate attributable number
#'
#' @param case_definition A character string - to be implemented
#' @param exposure_response_func A numeric vector of length 3, denoting the relative risk, lower confidence interval, upper confidence interval. Relative risk is per 10 unit change
#' @param theoretical_minimum_risk A numeric - to be implemented
#'
#' @return A data table of linked_pop_health_enviro with attached attributable number and confidence intervals.

do_health_impact_function <- function(
                 case_definition = 'crd',
                 exposure_response_func = c(1.06, 1.02, 1.08),
                 theoretical_minimum_risk = 0
               ){
  ## Note the case_definition and theoretical minimum risk are not yet implemented
  
  # this is a RR per 10 unit change
  unit_change <- 10
  beta <- log(exposure_response_func)/unit_change
  beta
  # ## so if x = 10
  # x <- 10
  # exp(beta * x)
  # ## or alternately
  # exposure_response_func^(x/10)
  
  resp_func <- function(x){
    res <- sapply(x, function(i)(exp(beta * i) -1))
    res <- t(res)
    res <- as.data.table(res)
    names(res) <- c("resp", "lci", "uci")
    return(res)
    
  }
  # resp_func(100)
  # resp_func(c(1,2,3,4,5))
  
  return(resp_func)
  
}
