do_health_impact_function <- function(
                 case_definition = 'crd',
                 exposure_response_func = c(1.06, 1.02, 1.08),
                 theoretical_minimum_risk = 0,
                 linked_pop_health_enviro = dat_linked_pop_health_enviro
               ){
  
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
    res <- sapply(x, function(i)(exp(beta * (i-theoretical_minimum_risk)) -1))
    res <- t(res)
    res <- as.data.table(res)
    names(res) <- c("resp", "lci", "uci")
    return(res)
    
  }
  # resp_func(100)
  # resp_func(c(1,2,3,4,5))
  
  return(resp_func)
  
}
