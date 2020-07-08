#!/usr/bin/Rscript
#
# File:    visualizeEcoli1.R
# Author:  Alex Stivala
# Created: November 2017
#
#Visualize (using igraph)
#the network data for the E. coli regulatory network (directed)
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
# is used (marked by coloring red not white)
# One versino has node size proportional to in-degree
# another to out-degree
#
# Usage:
# 
# Rscript visualizeEcoli1.R 
#
# Output files (WARNING overwritten)
# 
#    ecoli1_nodesize_indegree.eps
#    ecoli1_nodesize_outdegree.eps
#    
#

library(statnet)
library(intergraph)
library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeEcoli1.R\n")
  quit(save="no")
}

data(ecoli)
g <- asIgraph(ecoli1)
summary(g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)

V(g)$color <- ifelse(V(g)$self, 'red', 'white')

# generate the layout once, use it for both plots
layout <- layout.fruchterman.reingold(g)

postscript('ecoli1_network_outdegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()

postscript('ecoli1_network_indegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='in')/max(degree(g,mode='in'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()
