#' Calculate attributable number
#'
#' @param hif A function accepting a numeric vector argument (the delta) and returning three columns - attributable number, lower confidence interval and upper confidence interval.
#' @param linked_pop_health_enviro A data table of the study population with population-weighted exposure for baseline (x) and counterfactual (v1) scenarios
#'
#' @return A data table of linked_pop_health_enviro with attached attributable number and confidence intervals.

do_attributable_number <- function(
  hif,
  linked_pop_health_enviro){
  
  linked_pop_health_enviro[, c("attributable", "lci", "uci") := hif(v1) * expected]
  return(linked_pop_health_enviro)
}

# hif <- tar_read(health_impact_function)
# linked_pop_health_enviro <- tar_read(data_linked_pop_health_enviro)

