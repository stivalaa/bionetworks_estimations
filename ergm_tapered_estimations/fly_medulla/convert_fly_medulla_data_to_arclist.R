#!/usr/bin/env R

## Infuriatingly, cannot load graphml data on Linux (HPC) as
## "GraphML support is disabled", so have run script to just load
## Graphml and write to drosophila_medulla_1_arclist.txt
## for use in other programs or scripts that operate on Pajek R lists
library(igraph)
drosophila_medulla_1 <- read.graph('drosophila_medulla_1.graphml', format='graphml')
gs <- simplify(drosophila_medulla_1, remove.multiple = TRUE, remove.loops = TRUE)
summary(gs)
write.graph(gs, file = 'drosophila_medulla_1_arclist.txt', format='pajek')

## get named node subgraph
V(gs)$named <- (!grepl( "^[0-9].*", V(gs)$name))
gnamed <- induced.subgraph(gs, V(gs)[named == TRUE])
summary(gnamed)
write.graph(gnamed, file = 'drosophila_medulla_1_named_arclist.txt', format='pajek')
