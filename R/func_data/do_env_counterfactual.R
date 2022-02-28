do_env_counterfactual <- function(dt_exposure, 
                                  cf_mode = "min"){
  
  if(cf_mode == "min"){ # assumed non-anthropogenic component
    cf <- min(dt_exposure[, .(value)], na.rm = T)
    dt_exposure[, value_cf_red := (value - cf)]
  }
  
  return(dt_exposure)
}

# dt_exposure <- tar_read(data_env_exposure)
