#!/usr/bin/Rscript
#
# File:    convertWormPPIToEdgeList.R
# Author:  Alex Stivala
# Created: March 2017
#
# Read the CSV file for
# C. elegans protein-protein interaction network downloaded from
# http://rspgm.bionetworks.tk/
# and write edge list format for SMNet.
#
# Reference for data:
# 
#   Huang, X. T., Zhu, Y., Chan, L. L. H., Zhao, Z., & Yan, H. (2016).
#   An integrative C. elegans protein-protein interaction network with 
#   reliability assessment based on a probabilistic graphical model. 
#   Molecular BioSystems, 12(1), 85-92.
#
# Usage:
# 
# Rscript convertWormPPIToEdgeList.R 
#
# Output files (WARNING overwritten)
#    worm_ppi_edgelist.txt         - edge list Pajek format
#    worm_ppi_zones.txt            - snowball sample zones (all 0 full network)
#    worm_ppi_actors.txt           - node attributes
#    sampledesc.txt                - index to above files
#
#

library(igraph)

source("../../scripts/snowballSample.R")

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertWormPPIToEdgeList.R\n")
  quit(save="no")
}

D <-read.csv('PPIs_score_info.csv')
D$Gene_ID_a <- as.character(D$Gene_ID_a)
D$Gene_ID_b <- as.character(D$Gene_ID_b)
g <- graph.data.frame(data.frame(Gene_ID_a=D$Gene_ID_a, Gene_ID_b=D$Gene_ID_b), 
                      directed = FALSE, vertices = NULL)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

network_name <- "worm_ppi"
zonefilename <- paste(network_name, "_zones.txt", sep="")
edgelistfilename <- paste(network_name, "_edgelist.txt", sep="")
actorsfilename <- paste(network_name, "_actors.txt", sep="")

write.graph(g, edgelistfilename, format="pajek")

cat(vcount(g), zonefilename, edgelistfilename, actorsfilename,
    file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file(zonefilename, rep.int(0, vcount(g)))
write.graph(g, edgelistfilename, format="pajek")
write_subactors_file(actorsfilename, g)


