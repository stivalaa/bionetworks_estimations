#!/usr/bin/Rscript
#
# File:    convertDropshophilaMedullaToArcList.R
# Author:  Alex Stivala
# Created: November 2016
#
# Read the GraphML file for Drosophila Medulla synaptic interactions among
# neurons downloaded from NeuroData's Graph DataBase in Open Connectome 
# project at http://openconnecto.me/graph-services/download/
# and write Pajek arc list format.
#
# Citation for data is
#
#    Takemura, S.Y., Bharioke, A., Lu, Z., Nern, A., Vitaladevuni, S.,
#    Rivlin, P.K., Katz, W.T., Olbris, D.J., Plaza, S.M., Winston, P. and 
#    Zhao, T., 2013. A visual motion detection circuit suggested by 
#    Drosophila connectomics. Nature, 500(7461), pp.175-181.
#
#
# NB also using simplify() to remove multiple edges (and also loops) radically
# reduces from 25453 (undirected) edges (originally 33641 directed) 
# to only 8911 simple edges/
#
# Usage:
# 
# Rscript convertDropshophilaMedullaToArcList.R 
#
# Output files (WARNING overwritten)
#    fly_medulla_arclist.txt         - arc list Pajek format
#
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertDropshophilaMedullaToArcList.R\n")
  quit(save="no")
}

g <- read.graph("drosophila_medulla_1.graphml", format="graphml")
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

network_name <- "fly_medulla"
arclistfilename <- paste(network_name, "_arclist.txt", sep="")

write.graph(g, arclistfilename, format="pajek")
 
