#!/usr/bin/Rscript
#
# File:    visualizeWormPPIgraph.R
# Author:  Alex Stivala
# Created: March 2017
#
# Make PostScript file visualizeng the worm PPI graph
# 
# Writes to the file worm_ppi_graph.eps
#

library(igraph)

D <-read.csv('PPIs_score_info.csv')
D$Gene_ID_a <- as.character(D$Gene_ID_a)
D$Gene_ID_b <- as.character(D$Gene_ID_b)
g <- graph.data.frame(data.frame(Gene_ID_a=D$Gene_ID_a, Gene_ID_b=D$Gene_ID_b), 
                      directed = FALSE, vertices = NULL)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

postscript('worm_ppi_graph.eps')
plot(g , vertex.label=NA, vertex.size = 2,
     layout=layout.auto)
#     layout=layout.kamada.kawai)
#     layout=layout.fruchterman.reingold)
dev.off()


