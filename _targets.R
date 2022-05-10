library(targets)
library(tarchetypes)

sapply(list.files(pattern="[.]R$", path="R/", full.names=TRUE), source)

list(

tar_target(health_impact_function,
           do_health_impact_function(
             case_definition = 'crd',
             exposure_response_func = c(1.06, 1.02, 1.08),
             theoretical_minimum_risk = 0
           )
           ),

tar_target(dat_study_pop_health,
           do_study_pop_health(
             study_population,
             standard_pop_health
           )
           ),

tar_target(dat_exposure1_prep,
             load_exposure1(
               exposure1_raw
             )
             ),

tar_target(dat_counterfactual_exposures,
           do_counterfactual_exposures(
             delta_x
           )
         ),

tar_target(dat_exposures_counterfactual_linked,
           do_exposures_counterfactual_linked(
             exposure1_prep = dat_exposure1_prep,
             counterfactual_exposures = dat_counterfactual_exposures
           )
          ),

tar_target(dat_linked_pop_health_enviro,
             load_linked_pop_health_enviro(
               study_pop_health = dat_study_pop_health,
               exposures_counterfactual_linked = dat_exposures_counterfactual_linked
             )
             ),

tar_target(dat_attributable_number,
           do_attributable_number(
             hif = health_impact_function,
             linked_pop_health_enviro = dat_linked_pop_health_enviro
           )
           )

# end
)
