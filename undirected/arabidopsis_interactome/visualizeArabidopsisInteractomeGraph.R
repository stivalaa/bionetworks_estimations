#!/usr/bin/Rscript
#
# File:    visualizeArabidopsisInteractomeGraph.R
# Author:  Alex Stivala
# Created: November 2016
#
# Make PostScript file visualizeng the
# arabadopsis protein interactome graph from CCSB
# 
# Writes to the file arabadopsis_interactome_graph.eps
#

library(gdata)  # for reading .xls file
library(igraph)

D <- read.xls("AI_interactions.xls", sheet=1,header=TRUE)
g <- graph.edgelist(as.matrix(D[which(D$lci_binary == 1),c('ida','idb')]), 
                    directed=FALSE)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)


postscript('arabadopsis_interactome_graph.eps')
# plot with filled blue nodes for degree > 1, else empty (white) nodes
plot(g , vertex.label=NA, vertex.size = 2,
     vertex.color = sapply(degree(g),
                           function(d) if (d > 1) "blue" else "white"),
     layout=layout.fruchterman.reingold)
dev.off()


