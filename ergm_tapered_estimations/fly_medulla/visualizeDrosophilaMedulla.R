#!/usr/bin/Rscript
#
# File:    visualizeDrosophilaMedulla.R
# Author:  Alex Stivala
# Created: April 2019
#
#Visualize (using igraph)
#the network data for the Drosophilla medulla named subgraph
#
# Usage:
# 
# Rscript visualizeDrosophilaMedulla.R 
#
# Output files (WARNING overwritten)
# 
#    DrosophilaMedulla_nodesize_indegree.eps
#    DrosophilaMedulla_nodesize_outdegree.eps
#    
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeDrosophilaMedulla.R\n")
  quit(save="no")
}


g <- read.graph("drosophila_medulla_1_named_arclist.txt", format="Pajek")
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

V(g)$color <- "red"

# generate the layout once, use it for both plots
layout <- layout.fruchterman.reingold(g)

postscript('DrosophilaMedulla_network_outdegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()

postscript('DrosophilaMedulla_network_indegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='in')/max(degree(g,mode='in'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()
