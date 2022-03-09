library(targets)
library(tarchetypes)
library(bookdown)

source("R/packages.R")

tar_visnetwork()
#tar_make()

showme <- FALSE
if(showme){
  render_book( "index.Rmd", gitbook(split_by = "section", self_contained = FALSE, config = list(sharing = NULL, toc = list(collapse = "section"))) )
  browseURL("index.html")
}
