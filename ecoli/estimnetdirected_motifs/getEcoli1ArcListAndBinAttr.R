#!/usr/bin/Rscript
#
# File:    getEcoli1ArcListAndBinAttr.R
# Author:  Alex Stivala
# Created: November 2017
#
#Get the network data for the E. coli regulatory network (directed)
#as used (but undirected version)
#in Saul & Filkov 2007 and Hummel et al. 2012. The network is
#obtained from the ergm package data(ecoli) and other citations required
#are
#   Salgado et al (2001), Regulondb (version 3.2): Transcriptional
#     Regulation and Operon Organization in Escherichia Coli K-12,
#     _Nucleic Acids Research_, 29(1): 72-74.
#
#     Shen-Orr et al (2002), Network Motifs in the Transcriptional
#     Regulation Network of Escerichia Coli, _Nature Genetics_, 31(1):
#     64-68.
#
#
# self-loops are removed (although there are none anyway)
# Instead the binary attribute self used to mark self-regulating operons
# is used.
#
# Write in format for EstimNetDirected estimation.
#
# Usage:
# 
# Rscript getEcoli1ArcListAndBinAttr.R 
#
# Output files (WARNING overwritten)

#    ecoli1_arclist.txt         - arc list Pajek format
#

library(statnet)
library(intergraph)
library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: getEcoli1ArcListAndBinAttr.R\n")
  quit(save="no")
}

data(ecoli)
g <- asIgraph(ecoli1)
summary(g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)


network_name <- "ecoli1"
arclistfilename <- paste(network_name, "_arclist.txt", sep="")
binattrfilename <- paste(network_name, "_binattr.txt", sep="")

write.graph(g, arclistfilename, format="pajek")

# binary attributes
f <- file(binattrfilename, open="wt")
num_bin_attr <- 1 # self
cat("self\n", file=f) 
for (i in 1:vcount(g)) {
  for (j in 1:num_bin_attr) {
    cat(as.integer(V(g)$self[i]), file=f)
  }
  cat("\n", file=f)
}
close(f)


