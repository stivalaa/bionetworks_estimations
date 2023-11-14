#!/usr/bin/Rscript
#
# File:    taperedEstimateFlyMedullaNamedModel1.R
# Author:  Alex Stivala
# Created: June 2023
#
# Tapered ERGM model estimation of
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
# Uses the ergm.tapered R package:
#    https://github.com/statnet/ergm.tapered
#
# Citations for tapered ERGM:
#
# Blackburn, B., & Handcock, M. S. (2023). Practical Network Modeling via 
# Tapered Exponential-Family Random Graph Models. Journal of 
# Computational and Graphical Statistics, 32:2, 388-401
#
# Usage:
# 
# Rscript taperedEstimateFlyMedullaNamedModel1.R 
#
# Output files (WARNING overwritten)
#   fly_medulla_named_tapered_model1.txt
#   fly_medulla_named_tapered_model1_mcmcdiagnostics.eps
#   gof_fly_medulla_named1_tapered_model1.eps
#   fly_medulla_named_tapered_model1.RData
#

library(igraph)
library(statnet)
library(intergraph)
library(ergm.tapered)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

## Infuriatingly, cannot load graphml data on Linux (HPC) as
## "GraphML support is disabled", so have run script to just load
## Graphml and write to drosophila_medulla_1.graphml.RData 
## on Windows PC (cygwin) and copy that to Linux server.
## It's always just one thing after another with R....
###g <- read.graph('drosophila_medulla_1.graphml', format='graphml')
g  <- readRDS('drosophila_medulla_1.rds')
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

summary(gn, print.adj=FALSE)

system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed = TRUE) + gwodegree(0.2, fixed = TRUE) + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

# does not converge:
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwidegree + gwodegree + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

print(tapered_model1)
summary(tapered_model1, extended = TRUE)

postscript('fly_medulla_named_tapered_model1_mcmcdiagnostics.eps')
mcmc.diagnostics(tapered_model1)
dev.off()

sink('fly_medulla_named_tapered_model1.txt')
print( summary(tapered_model1, extended = FALSE) )
sink()

save(gn, tapered_model1, file = "fly_medulla_named_tapered_model1.RData")

system.time( tapered_model1_gof <-  gof(tapered_model1, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model) )
print(tapered_model1_gof)
postscript('fly_medulla_named_tapered_model1_gof.eps')
par(mfrow=c(4,2))
plot( tapered_model1_gof, plotlogodds=TRUE)
dev.off()

warnings()

