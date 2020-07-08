#!/usr/bin/Rscript
#
# File:    getEcol2EdgeList.R
# Author:  Alex Stivala
# Created: November 2016
#
#Get the network data for the E. coli regulatory network (undircted)
#as used in Saul & Filkov 2007 and Hummel et al. 2012. The network is
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
# Usage:
# 
# Rscript getEcoli2EdgeList.R edgelist_filename
#
#    edgelist_filename is outputadjacency list (WARNING: overwritten)
#

library(statnet)
library(intergraph)
library(igraph)

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  cat("Usage: getEcoli2EdgeList.R out_edgelist_file\n")
  quit(save="no")
}
output_edgelist_filename <- args[1]

data(ecoli)
g <- asIgraph(ecoli2)
summary(g)
write.graph(g, output_edgelist_filename, format="pajek")

