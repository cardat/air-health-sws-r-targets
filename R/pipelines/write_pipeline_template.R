## Write out a _targets.R script from template_targets.R

write_pipeline <- function() {
  
  # check before overwriting
  if (file.exists("_targets.R")){
    resp <- utils::menu(c("yes", "no"), title = "_targets.R already exists. Overwrite?")
    print(resp)
    if(!identical(as.integer(resp), 1L)) return(invisible())
  }
  
  script <- readLines("R/pipelines/template_targets.R")
  writeLines(script, "_targets.R")
}
