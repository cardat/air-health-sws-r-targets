do_env_counterfactual <- function(dt_exposure, 
                                  cf_mode = "abs",
                                  cf_value){
  
  if(cf_mode == "min"){ # assumed non-anthropogenic component
    cf_value <- min(dt_exposure[, .(value)], na.rm = T)
    dt_exposure[, cf := cf_value]
    
  } else if (cf_mode == "abs") {
    stopifnot("Provide a counterfactual absolute value in 'abs' mode" = !missing(cf_value))
    dt_exposure[, cf := cf_value]
    dt_exposure[cf > value, cf := value]
  }
  dt_exposure[, delta := (value - cf)]
  
  return(dt_exposure)
}

# dt_exposure <- tar_read(data_env_exposure)
