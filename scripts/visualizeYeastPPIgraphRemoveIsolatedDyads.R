#!/usr/bin/Rscript
#
# File:    visualizeYeastPPIgraphREmoveISolatedDyads.R
# Author:  Alex Stivala
# Created: November 2016
#
# Make PostScript file visualizeing the
# yeast protein interaction network from Nexus 
# This version removes isolated dyads (nodes od dgree 1)
# 
# Ref for network from Nexus is:
#
#   Christian von Mering, Roland Krause, Berend Snel, Michael Cornell, 
#   Stephen G. Oliver, Stanley Fields & Peer Bork, Comparative assessment 
#   of large-scale data sets of protein.protein interactions, 
#   Nature 417, 399-403 (2002)
#
# Writes to the file yeast_ppi_no_isolated_dyads.eps
#

library(igraph)


#
# node_is_in_isolated_dyad() -TRUE if node v is part of isolated dyad (undirected)
#
node_is_in_isolated_dyad <- function(g, v) {
  return(degree(g, v) == 1 & degree(g, neighbors(g, v)[1]) == 1)
}

# is_in_isolated_dyad() - vector over whole graph of node_in_isoaltd_dyad()
is_in_isolated_dyad <- function(g) {
  return(sapply(V(g), function(v) node_is_in_isolated_dyad(g, v)))
}

#
# main
#

g <- nexus.get("yeast")
summary( g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)

g <- induced.subgraph(g, V(g)[which(!is_in_isolated_dyad(g))])
summary(g)

# convert NA Class to "U" (uncharacterized)
# [not sure why there is both "U" and NA]
V(g)$Class[which(is.na(V(g)$Class))] <- "U"

# convert class to integer for categorical attribute
V(g)$class_cat <- unclass(factor(V(g)$Class))

V(g)$color <- V(g)$class_cat
postscript('yeast_ppi_no_isolated_dyads.eps')
plot(g , vertex.label=NA, vertex.size = 4,
     vertex.color=V(g)$color, 
#     layout=layout.kamada.kawai)
#     layout=layout.auto)
     layout=layout.fruchterman.reingold)
dev.off()


