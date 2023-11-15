#!/usr/bin/Rscript
#
# File:    lologEstimateFlyMedullaNamedModel1.R
# Author:  Alex Stivala
# Created: November 2023
#
# LOLOG model estimation of
# the network data for Drosophila medulla connectome
#
# Reads the GraphML file for Drosophila Medulla synaptic interactions among
# neurons downloaded from NeuroData's Graph DataBase in Open Connectome
# project at http://openconnecto.me/graph-services/download/
#
# Citation for data is
#
#    Takemura, S.Y., Bharioke, A., Lu, Z., Nern, A., Vitaladevuni, S.,
#    Rivlin, P.K., Katz, W.T., Olbris, D.J., Plaza, S.M., Winston, P. and
#    Zhao, T., 2013. A visual motion detection circuit suggested by
#    Drosophila connectomics. Nature, 500(7461), pp.175-181.
#
# and for the Open Connectome databse where it was obtained:
#
#   Vogelstein, J. T., Perlman, E., Falk, B., Baden, A.,
#   Gray Roncal, W., Chandrashekhar, V., ... & Burns, R. (2018).
#   A community-developed open-source computational ecosystem for
#   big neuro data. Nature methods, 15(11), 846-847.
#
# Following this paper:
#
#
#    Susama Agarwala , Franklin Kenter, A geometric Chung-Lu model 
#    and the Drosophila medulla connectome, Journal of Complex Networks,
#    Volume 11, Issue 3, June 2023, cnad010,
#     https://doi.org/10.1093/comnet/cnad010 
#
#
# we assign 3D geometric locations to the neurons using the centroids
# of the synaptic coordinates associated wth them.
# Also, the "named" subgraph is extracted: this is the subgraph induced
# by the neurons that have alphanumeric labels (not just numbers).
# (see Agarwala et al. 2023 and TAkemura et al. 2013 for details).
# Unlike that paper, however, we do NOT remove the highest-degree node(s),
# but self-loops ARE removed (statnet ergm cannot handle them).
#
#
# Usage:
# 
# Rscript lologEstimateFlyMedullaNamedModel1.R 
#
# Output files (WARNING overwritten)
# Model and GoF output is to stdout, also writes output files to cwd:
#   drosophilla_medulla_lolog_model1.txt
#   drosophilla_medulla_lolog_model1.pdf
#   gof_drosophilla_medulla1_lolog_model1_X.pdf
#       where X is a statistic e.g. indegree, outdegree, esp, etc.
# WARNING: overwrites output files if they exist
###
#

library(igraph)
library(statnet)
library(intergraph)
library(lolog)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

## Infuriatingly, cannot load graphml data on Linux (HPC) as
## "GraphML support is disabled", so have run script to just load
## Graphml and write to drosophila_medulla_1.graphml.RData 
## on Windows PC (cygwin) and copy that to Linux server.
## It's always just one thing after another with R....
###g <- read.graph('drosophila_medulla_1.graphml', format='graphml')
g  <- readRDS('../../ergm_tapered_estimations/fly_medulla/drosophila_medulla_1.rds')
summary(g)


## get centroids of nodes from 'pre' coordinates of outgoing arcs and
##'post' coordinates of incoming arcs
centroids <- data.frame(x = rep(NA, vcount(g)),  y = rep(NA, vcount(g)), z = rep(NA, vcount(g)))
system.time(centroids$x <- sapply(1:vcount(g), function(u) mean(c(incident(g, V(g)[u], mode = 'in')$post.x, incident(g, V(g)[u], mode = 'out')$pre.x))))
system.time(centroids$y <- sapply(1:vcount(g), function(u) mean(c(incident(g, V(g)[u], mode = 'in')$post.y, incident(g, V(g)[u], mode = 'out')$pre.y))))
system.time(centroids$z <- sapply(1:vcount(g), function(u) mean(c(incident(g, V(g)[u], mode = 'in')$post.z, incident(g, V(g)[u], mode = 'out')$pre.z))))
## Absurdly slow R: each of the above 3 lines of code takes approx. 1 min. each
V(g)$x <- centroids$x
V(g)$y <- centroids$y
V(g)$z <- centroids$z

gs <- simplify(g, remove.multiple = TRUE, remove.loops = TRUE)
summary(gs)

## get named node subgraph
V(gs)$named <- (!grepl( "^[0-9].*", V(gs)$name))
gnamed <- induced.subgraph(gs, V(gs)[named == TRUE])
summary(gnamed)

## build distance matrix for nodes in gnamed
centroids_named <- data.frame(x = rep(NA, vcount(gnamed)),  y = rep(NA, vcount(gnamed)), z = rep(NA, vcount(gnamed)))
centroids_named$x <- V(gnamed)$x
centroids_named$y <- V(gnamed)$y
centroids_named$z <- V(gnamed)$z
distmatrix_named <- as.matrix(dist(centroids_named))


gn <- asNetwork(gnamed)

maxindeg <- max(degree(gn, cmode='indegree'))
maxoutdeg <- max(degree(gn, cmode='outdegree'))

summary(degree(gn, cmode='indegree'))
summary(degree(gn, cmode='outdegree'))


summary(gn, print.adj=FALSE)


system.time( drosophilla_medulla_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out') + edgeCov(distmatrix_named) + mutual) )

summary(drosophilla_medulla_lolog_model1)
sink('drosophilla_medulla_lolog_model1.txt')
summary(drosophilla_medulla_lolog_model1)
sink()

pdf('drosophilla_medulla_lolog_model1.pdf')
plot(drosophilla_medulla_lolog_model1)
dev.off()

system.time( gof_drosophilla_medulla_lolog_model1_indegree <- gofit(drosophilla_medulla_lolog_model1, gn ~ degree(0:maxindeg, direction='in')))
system.time( gof_drosophilla_medulla_lolog_model1_outdegree <- gofit(drosophilla_medulla_lolog_model1, gn ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_drosophilla_medulla_lolog_model1_esp <- gofit(drosophilla_medulla_lolog_model1, gn ~ esp(0:25)) )
system.time( gof_drosophilla_medulla_lolog_model1_edges <- gofit(drosophilla_medulla_lolog_model1, gn ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_drosophilla_medulla_lolog_model1_indegree.pdf')
plot(gof_drosophilla_medulla_lolog_model1_indegree)
dev.off()
pdf('gof_drosophilla_medulla_lolog_model1_outdegree.pdf')
plot(gof_drosophilla_medulla_lolog_model1_outdegree)
dev.off()
pdf('gof_drosophilla_medulla_lolog_model1_esp.pdf')
plot(gof_drosophilla_medulla_lolog_model1_esp)
dev.off()
pdf('gof_drosophilla_medulla_lolog_model1_edges.pdf')
plot(gof_drosophilla_medulla_lolog_model1_edges, type='box')
dev.off()

