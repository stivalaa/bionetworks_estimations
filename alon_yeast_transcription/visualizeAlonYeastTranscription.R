#!/usr/bin/Rscript
#
# File:    visualizeAlonYeastTranscription.R
# Author:  Alex Stivala
# Created: April 2019
#
#Visualize (using igraph)
#the network data for the yeast transcription factor intreaction network
#
# Usage:
# 
# Rscript visualizeAlonYeastTranscription.R 
#
# Output files (WARNING overwritten)
# 
#    yeast_transcription_nodesize_indegree.eps
#    yeast_transcription_nodesize_outdegree.eps
#    
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: visualizeAlonYeastTranscription.R\n")
  quit(save="no")
}


yeastinter <- read.table("yeastinter_st.txt", header = FALSE)

# from yeastreadme.doc:
#
#   yeastInter_st.txt is a text file that includes all the interactions
#   in the network. The convention used in the file is that the order of
#   the columns is: regulating gene (TF), regulated gene, mode of
#   regulation.  In the basic yeastInter.txt network the mode of
#   regulation is always 1, we did not differentiate between activators
#   and repressors. See below for information on datasets that include the
#   mode of regulation.

yeastinter$V3 <- NULL # drop 3rd column (always 1 for regulation mode)
g <- graph.edgelist(as.matrix(yeastinter))

summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

V(g)$color <- "red"

# generate the layout once, use it for both plots
layout <- layout.fruchterman.reingold(g)

postscript('yeast_transcription_network_outdegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='out')/max(degree(g,mode='out'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()

postscript('yeast_transcription_network_indegree.eps', onefile=TRUE, paper="special",height=6, width=9)
plot(g , vertex.label=NA, vertex.size = 10*degree(g, mode='in')/max(degree(g,mode='in'))+2, vertex.color=V(g)$color, layout=layout, edge.arrow.size=0.3)
dev.off()
