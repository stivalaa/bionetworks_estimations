#!/usr/bin/Rscript
#
# File:    convertHumanInteractomeToEdgeList.R
# Author:  Alex Stivala
# Created: November 2016
#
# Read the TSV file for 
# network of protiein-protein interation among human proteins
# derived via yeast two-hybrid (Y2H) experiments (HI-II-14).
# downloaded from 
# http://interactome.dfci.harvard.edu/H_sapiens/index.php?page=download
# and write edge list format for SMNet.
#
# Reference for data:
# 
#   Rolland, T., Tasan, M., Charloteaux, B., Pevzner, S.J., Zhong, Q., 
#   Sahni, N., Yi, S., Lemmens, I., Fontanillo, C., Mosca, R. and Kamburov, A., 
#   2014. A proteome-scale map of the human interactome network. 
#
# Usage:
# 
# Rscript convertHumanInteractomeToEdgeList.R 
#
# Output files (WARNING overwritten)
#    human_interactome_edgelist.txt         - edge list Pajek format
#    human_interactome_zones.txt            - snowball sample zones (all 0 full network)
#    human_interactome_actors.txt           - node attributes
#    sampledesc.txt                   - index to above files
#
#

library(igraph)

source("../../scripts/snowballSample.R")

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertHumanInteractomeToEdgeList.R\n")
  quit(save="no")
}

D <-read.table('HI-II-14.tsv', header=TRUE, sep='\t')
g <- graph.edgelist(as.matrix(D[c('Symbol.A','Symbol.B')]),directed=FALSE)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

network_name <- "human_interactome"
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


