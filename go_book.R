library(bookdown)

render_book( "index.Rmd", gitbook(split_by = "chapter", 
                                  self_contained = FALSE, 
                                  config = list(sharing = NULL, toc = list(collapse = "section"))) )

flist <- dir("_book", full.names = T)
for(fi in flist){
  #fi <- flist[1]
  file.rename(fi, gsub("_book/", "", fi))
}
browseURL("index.html")
  