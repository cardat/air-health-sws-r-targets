do_attributable_number <- function(
  hif,
  linked_pop_health_enviro){
  
  linked_pop_health_enviro[, c("attributable", "lci", "uci") := hif(v1) * expected]
  return(linked_pop_health_enviro)
}

# hif <- tar_read(health_impact_function)
# linked_pop_health_enviro <- tar_read(data_linked_pop_health_enviro)

