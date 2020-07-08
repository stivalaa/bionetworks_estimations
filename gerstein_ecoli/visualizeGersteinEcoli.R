#!/usr/bin/env Rscript
#
# File:    visualizeGersteinEcoliRegulatory.R
# Author:  Alex Stivala
# Created: April 2019
#
#Visualize (using igraph)
#the network data for the ecoli regulatory network (directed)
#
# self-loops are removed (although there are none anyway as removed
# byt hte Python/igraph script that gets the data).
# Instead the binary attribute self used to mark self-regulating operons
# is used (marked by coloring red not white)
# One versino has node size proportional to in-degree
# another to out-degree
#
# Usage:
# 
# Rscript visualizeGersteinEcoliRegulatory.R 
#
# Output files (WARNING overwritten)
# 
#    ecoli_regulatory_nodesize_indegree.eps
#    ecoli_regulatory_nodesize_outdegree.eps
#    
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeGersteinEcoliRegulatory.R\n")
  quit(save="no")
}

g <- read.graph('ecoli_arclist.txt', format='pajek')
binattr <- read.table('ecoli_binattr.txt', header=TRUE)
V(g)$self <- ifelse(binattr$self == 1, TRUE, FALSE)
summary(g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)

V(g)$color <- ifelse(V(g)$self, 'red', 'white')

# generate the layout once, use it for both plots
#layout <- layout.fruchterman.reingold(g)
#layout <- layout.lgl(g)
#layout <- layout.auto(g)
layout <- layout.kamada.kawai(g)

postscript('ecoli_regulatory_network_outdegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()

postscript('ecoli_regulatory_network_indegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='in')/max(degree(g,mode='in'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()
