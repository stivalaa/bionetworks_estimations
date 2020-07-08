#!/usr/bin/Rscript
#
# File:    visualizeMouseRetinaGraph.R
# Author:  Alex Stivala
# Created: May 2019
#
#Visualize (using igraph)
#the network data for the mouse retina neural network
#
# Usage:
# 
# Rscript visualizeMouseRetinaGraph.R 
#
# Output files (WARNING overwritten)
# 
#    mouse_retina_nodesize_degree.eps
#    
#

library(igraph)
library(RColorBrewer)



# Data frm Table II of Glasbey et al 2007 "Colour Displays for Categorical
# Images" Color Research and Application 32(4):304-309
# These are the first 32 colours found by sequential search to solve
# their formulation of maximizing the minimimum distance between colours
# (in the CIELAB colour space).
# These are the RGB tuple values of those colors (each in [0,255]).
# Use to obtain a list of up to 32 colors that are "maximally distinguishable"
# ie to human perception are least likely to be confused.
# Used in color.py from Pro-origami code
GLASBEY_COLORS     <- list(c(255, 255, 255),
                      c(  0,   0, 255),
                      c(255,   0,   0),
                      c(  0, 255,   0),
                      c(  0,   0,  51),
                      c(255,   0, 182),
                      c(  0,  83,   0),
                      c(255, 211,   0),
                      c(  0, 159, 255),
                      c(154,  77,  66),
                      c(  0, 255, 190),
                      c(120,  63, 193),
                      c( 31, 150, 152),
                      c(255, 172, 253),
                      c(177, 204, 113),
                      c(241,   8,  92),
                      c(254, 143,  66),
                      c(221,   0, 255),
                      c( 32,  26,   1),
                      c(114,   0,  85),
                      c(118, 108, 149),
                      c(  2, 173,  36),
                      c(200, 255,   0),
                      c(136, 108,   0),
                      c(255, 183, 159),
                      c(133, 133, 103),
                      c(161,   3,   0),
                      c( 20, 249, 255),
                      c(  0,  71, 158),
                      c(220,  94, 147),
                      c(147, 212, 255),
                      c(  0,  76, 255)
                      )

# Get R rgb values by normalizing values to [0,1] interval and getting rbg()
# value and omitting fast colour # which is white.
GLASBEY_RGB_LIST <-  lapply(GLASBEY_COLORS[2:length(GLASBEY_COLORS)], 
                                  function(v) rgb(v[1]/255, v[2]/255, v[3]/255))

# Add some extra colours from RColorBrewer.
RGB_LIST <- c(GLASBEY_RGB_LIST, brewer.pal(8, 'Dark2'))

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeMouseRetinaGraph.R\n")
  quit(save="no")
}



g <- read.graph("mouse_retina_1.graphml", format="graphml")
g <- as.undirected(g)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

setNA <- function(x) { if (x == "NA" | x == "") as.character(NA) else as.character(x) }
# Does not work if V(g)$designation used, only if new variable designation used.
# Why is R always so difficult and arbitrary?
designation <- V(g)$designation
designation <- sapply(designation, setNA)
designation <- as.factor(designation)

print(levels(designation))

num_classes <- length(levels(designation))
cat('num_classes == ', num_classes, '\n')
stopifnot(nlevels(designation) == num_classes)

if (num_classes <= length(RGB_LIST)) {
    colour_list <- RGB_LIST
} else {
    colour_list <- as.list(rainbow(num_classes))
}
vcolours <- sapply(as.numeric(designation), 
                   function(x) ifelse(is.na(x), gray(0.7), colour_list[[x]]))
V(g)$color <- vcolours

# generate the layout once, use it for both plots
#does not work: layout <- layout.fruchterman.reingold(g)
layout <- layout.kamada.kawai(g)

postscript('mouse_retina_network_degree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout)
if (num_classes <= 100) { # if too many, legend is just a mess
    num_legend_rows <- 5
    num_legend_cols <- ceiling(num_classes / num_legend_rows)
    legend('bottom', ncol=num_legend_cols,
          legend=levels(designation),
          col=unlist(colour_list)[1:num_classes],
          title="Designation",
          cex=0.6,
          pch=15,
          bty='n')
}
dev.off()

