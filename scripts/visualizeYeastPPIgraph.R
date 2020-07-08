#!/usr/bin/Rscript
#
# File:    visualizeYeastPPIgraph.R
# Author:  Alex Stivala
# Created: November 2016
#
# Make PostScript file visualizeing the
# yeast protein interaction network from Nexus 
# 
# Ref for network from Nexus is:
#
#   Christian von Mering, Roland Krause, Berend Snel, Michael Cornell, 
#   Stephen G. Oliver, Stanley Fields & Peer Bork, Comparative assessment 
#   of large-scale data sets of protein.protein interactions, 
#   Nature 417, 399-403 (2002)
#
# Writes to the file yeast_ppi.eps
#

library(igraph)

g <- nexus.get("yeast")
summary( g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)

# convert NA Class to "U" (uncharacterized)
# [not sure why there is both "U" and NA]
V(g)$Class[which(is.na(V(g)$Class))] <- "U"

# convert class to integer for categorical attribute
V(g)$class_cat <- unclass(factor(V(g)$Class))

V(g)$color <- V(g)$class_cat
postscript('yeast_ppi.eps')
plot(g , vertex.label=NA, vertex.size = 4,
     vertex.color=V(g)$color, 
#     layout=layout.kamada.kawai)
#     layout=layout.auto)
     layout=layout.fruchterman.reingold)
dev.off()


