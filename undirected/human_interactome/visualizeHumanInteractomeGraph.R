#!/usr/bin/Rscript
#
# File:    visualizeHumanInteractomeGraph.R
# Author:  Alex Stivala
# Created: November 2016
#
# Make PostScript file visualizeng the
# human protein interactome graph from CCSB
# 
# Writes to the file human_interactome_graph.eps
#

library(igraph)

D <-read.table('HI-II-14.tsv', header=TRUE, sep='\t')
g <- graph.edgelist(as.matrix(D[c('Symbol.A','Symbol.B')]),directed=FALSE)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

postscript('human_interactome_graph.eps')
plot(g , vertex.label=NA, vertex.size = 4,
     layout=layout.fruchterman.reingold)
dev.off()


