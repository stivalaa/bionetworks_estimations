#!/usr/bin/Rscript
#
# File:    visualizeFlyMedullaGraph.R
# Author:  Alex Stivala
# Created: April 2019
#
#Visualize (using igraph)
#the network data for the fly medulla neural network
#
# Usage:
# 
# Rscript visualizeFlyMedullaGraph.R 
#
# Output files (WARNING overwritten)
# 
#    fly_medulla_nodesize_indegree.eps
#    fly_medulla_nodesize_outdegree.eps
#    
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeFlyMedullaGraph.R\n")
  quit(save="no")
}



g <- read.graph("drosophila_medulla_1.graphml", format="graphml")

summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

V(g)$color <- "red"

# generate the layout once, use it for both plots
# does not work: layout <- layout.fruchterman.reingold(g)
layout <- layout.kamada.kawai(g)

postscript('fly_medulla_network_outdegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()

postscript('fly_medulla_network_indegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='in')/max(degree(g,mode='in'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()
