# setwd("..")
library(targets)
if(!require(disentangle)) {
  library(devtools)
  install_github("ivanhanigan/disentangle")
}
library(disentangle)
library(stringr)

t_mf <- tar_glimpse()
str(t_mf)
# t_mf

nd <- t_mf$x$nodes
ed <- t_mf$x$edges
row.names(nd) <- NULL
row.names(ed) <- NULL

nd
ed

nd_todo = "dat_attributable_number"
nd[nd$name == nd_todo,]
ed[ed$from == nd_todo,]
ed[ed$to == nd_todo,]

steps <- merge(nd[,c("name", "id")], ed[,c("from","to")], by.x="name", by.y = "to", all.x = T)
steps$to <- steps$id
steps$id <- NULL

#steps <- read.csv("apmma-mindmap.csv", stringsAsFactors = F)
steps
#steps <- steps[steps$PM25 %in% "TODO1",]
#steps <- steps[!(steps$STATUS %in% "DONTSHOW"),]

steps$DESCRIPTION <- steps$name
# paste0(substr(steps$DESCRIPTION, 1, 24), "...")
#steps$DESCRIPTION <- paste0(substr(steps$CODE, 1, 24), "...")
steps$CLUSTER <- "all"
steps$STATUS <- "DONE"

nodes <- newnode(steps, "name", "from", "to", "CLUSTER", todo_col="STATUS")

# to run this graph sideways
sideways <- F
if(sideways){
nodes <- gsub("digraph transformations \\{", "digraph transformations \\{ rankdir=LR;", nodes)
nodes <- gsub('label="\\{\\{', 'label="\\{', nodes)
nodes <- gsub('\\{\\{]', '\\{]', nodes)
}
dir()
sink("mindmap_plan.dot")
cat(nodes)
sink()

make_mindmap_png <- function(dot_filename = "mindmap_plan", showme = TRUE){
# https://github.com/rich-iannone/DiagrammeR/issues/330#issuecomment-766090870
# 1. Make a play graph
#DiagrammeR::grViz("apmma_mindmap_plan.dot")
tmp <- DiagrammeR::grViz(sprintf("%s.dot", dot_filename))
# 2. Convert to SVG, then save as png
tmp <- DiagrammeRsvg::export_svg(tmp)
tmp <- charToRaw(tmp) # flatten
rsvg::rsvg_png(tmp, sprintf("%s.png", dot_filename)) # saved graph as png in current working directory

# If graphviz is installed and on linux
#system("dot -Tpdf apmma_mindmap_plan.dot -o apmma_mindmap_plan.pdf")
#if(show_mindmap) browseURL("apmma_mindmap_plan.pdf")
if(showme){
browseURL(sprintf("%s.png", dot_filename))
}
}

make_mindmap_png()

#### or ####
library(DiagrammeR)
steps$tocolour <- ""
steps$pos <- NA
names(steps)
steps[,c("from", "to")]

#### format the table again ####
steps_list <- unique(steps$to)

steps2 <- data.frame(from=NA, to=NA, tocolour=NA, pos=NA)
for(step_i in steps_list){
  ##step_i = steps_list[1]
  step_i
  inputs <- steps[steps$to==step_i,"from"]
  inputs2 <- paste(inputs, sep = "", collapse = ", ")
  dout <- data.frame(from=inputs2, to=step_i, tocolour='', pos='')
  steps2 <- rbind(steps2,dout)
}
steps2 <- steps2[-1,]
steps2
steps2[,c("from", "to")]
## cf
steps[,c("from", "to")]

#### do the graph ####
dotty <- newgraph(
    indat2  = steps2[steps2$from != "NA",]
   ,
    in_col = "from"
   ,
    out_col  = "to"
   ,
    colour_col = "tocolour"
   ,
    pos_col = "pos"
    )
##
render_graph(dotty)
dotty1 <- generate_dot(dotty)
cat(dotty1)
substr(dotty1, 1, 446)
dotty2  <- c(
"digraph {

splines = true; 
node [fontname = Helvetica,
      style = filled]
 edge [color = gray20,
      arrowsize = 1,
      fontname = Helvetica]",
substr(dotty1, 446, nchar(dotty1))
)

## render_graph(dotty)
sink("mindmap_plan.dot")  
cat(gsub("'",'"', dotty2))
sink()
make_mindmap_png()

#### dump the table of steps for clerical review ####
# write.csv(steps, "foo.csv", row.names = F)

steps <- read.csv("foo2.csv")

steps <- steps[steps$STATUS != 'DONTSHOW', ]

nodes <- newnode(steps, "name", "from", "to", clusters_col = "CLUSTER", todo_col="STATUS")

# to run this graph sideways
sideways <- T
if(sideways){
nodes <- gsub("digraph transformations \\{", "digraph transformations \\{ rankdir=LR;", nodes)
nodes <- gsub('label="\\{\\{', 'label="\\{', nodes)
nodes <- gsub('\\{\\{]', '\\{]', nodes)
}
dir()
sink("mindmap_plan.dot")
cat(nodes)
sink()

make_mindmap_png()
