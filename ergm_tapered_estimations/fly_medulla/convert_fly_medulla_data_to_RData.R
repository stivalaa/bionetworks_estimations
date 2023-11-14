#!/usr/bin/env R

## Infuriatingly, cannot load graphml data on Linux (HPC) as
## "GraphML support is disabled", so have run script to just load
## Graphml and write to drosophila_medulla_1.graphml.rds
## on Windows PC (cygwin) and copy that to Linux server.
library(igraph)
drosophila_medulla_1 <- read.graph('drosophila_medulla_1.graphml', format='graphml')
saveRDS(drosophila_medulla_1, file = 'drosophila_medulla_1.rds')

# now can load with drosophila_medulla_1  <- readRDS('drosophila_medulla_1.rds')
