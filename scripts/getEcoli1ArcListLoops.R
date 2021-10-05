#!/usr/bin/env Rscript
# File:    getEcoli1ArcListLoops.R
# Author:  Alex Stivala
# Created: September 2021
#
# Get the network data for the E. coli regulatory network (directed)
# as used (but undirected version)
# in Saul & Filkov 2007 and Hummel et al. 2012. The network is
# obtained from the ergm package data(ecoli) and other citations required
# are
#   Salgado et al (2001), Regulondb (version 3.2): Transcriptional
#     Regulation and Operon Organization in Escherichia Coli K-12,
#     _Nucleic Acids Research_, 29(1): 72-74.
#
#     Shen-Orr et al (2002), Network Motifs in the Transcriptional
#     Regulation Network of Escerichia Coli, _Nature Genetics_, 31(1):
#     64-68.
#
# In this version we explicitly add self-edges (loops) by putting
# a self-edge v->v for every node v that has the 'self' attribute
# True (marking it as a node with a self-edge).
#
# Write in Pajek format (used for EstimNetDirected estimation e.g.)
#
# Usage:
# 
# Rscript getEcoli1ArcListAndBinAttr.R 
#
# Output files (WARNING overwritten)
#    ecoli1_arclist_loops.txt         - arc list Pajek format
#
#
# From '?ecoli' in statnet:
#    The network object 'ecoli1' is directed, with 423 nodes and 519
#     arcs. The object 'ecoli2' is an undirected version of the same
#     network, in which all arcs are treated as edges and the five
#     isolated nodes (which exhibit only self-regulation in 'ecoli1')
#     are removed, leaving 418 nodes.
# 
# So this uses ecoli1 and so we end up with a 423 node network
# and the 5 nodes that are isolates each have a self-edge.


library(statnet)
library(igraph)
library(intergraph)
data(ecoli)
g <- asIgraph(ecoli1)
g <- add_edges(g, unlist(lapply(which(V(g)$self), function(x) c(x,x))))
write.graph(g, 'ecoli1_arclist_loops.txt', format='pajek')
summary(g)
