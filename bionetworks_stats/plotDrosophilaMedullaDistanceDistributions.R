#!/usr/bin/Rscript
#
# File:    plotDrosophilaMedullaDistanceDistributions.R
# Author:  Alex Stivala
# Created: November 2023
#
# Make PostScript files plotting the distribnutions of
# 3D Euclidean distances between all edges in the network
# and also all pairwise distances between nodes. 
# 
# Usage: Rscript plotDrosophilaMedullaDistanceDistributions.R
#
# Writes output distance_distributions_distance_distributions.eps to cwd
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

library(igraph)


sessionInfo()

# Eucliean distance (3 dimensions) between two nodes
dist_between_nodes <- function(v1, v2) {
  v1point <- c(v1$x, v1$y, v1$z)
  v2point <- c(v2$x, v2$y, v2$z)
  return(dist(rbind(v1point, v2point)))
}



g <- read.graph('../ergm_tapered_estimations/fly_medulla/drosophila_medulla_1.graphml', format='graphml')
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




ug <- as.undirected(gnamed)
summary(ug)



cat('Computing all edge distances...\n')
system.time(  all_edge_distances <- sapply(1:ecount(ug), FUN=function(i) dist_between_nodes( V(ug)[get.edgelist(ug)[i,1]]  , V(ug)[get.edgelist(ug)[i,2]] ) )  )
print(length(all_edge_distances))
print(summary(all_edge_distances))

cat('Computing all pairwise distances...\n')
system.time( all_pairwise_distances_matrix <- outer(1:vcount(ug), 1:vcount(ug), FUN=Vectorize(function(i, j) dist_between_nodes(V(ug)[i], V(ug)[j]))) )
# convert upper triangle only to vector of distances (distance matrix symmetric with diagonal zero)
all_pairwise_distances <- c(all_pairwise_distances_matrix[upper.tri(all_pairwise_distances_matrix)])
print(length(all_pairwise_distances))
print(summary(all_pairwise_distances))



output_postscript_filename <- 'drosophila_medulla_distance_distributions.eps'
# for inclusion in LaTeX or epstopdf, stop it rotating it
postscript(output_postscript_filename,
           paper="special", horizontal=FALSE, width=9, height=6)
par(mfrow=c(2, 2))

# histogram
hist(all_edge_distances, xlab=expression("Distance (" * mu * "m)"), main='Drosophila medulla synapse distances')
abline(v = mean(all_edge_distances), col = 'blue')
# cumulative distribution, log-log plot
dtab <- table(all_edge_distances)
plot(as.numeric(names(dtab)), 1-cumsum(as.numeric(dtab)/length(dtab)), log='xy', xlab=expression("Distance (" * mu * "m)"), ylab='CDF', ylim=c(0.00001,1), xlim=c(1, 10000), type='l')

# histogram
hist(all_pairwise_distances, xlab=expression("Distance (" * mu * "m)"), main='Drosophila medulla all pairwise neuron distances')
abline(v = mean(all_pairwise_distances), col = 'blue')
# cumulative distribution, log-log plot
dtab <- table(all_pairwise_distances)
plot(as.numeric(names(dtab)), 1-cumsum(as.numeric(dtab)/length(dtab)), log='xy', xlab=expression("Distance (" * mu * "m)"), ylab='CDF', ylim=c(0.00001,1), xlim=c(1, 10000), type='l')
dev.off()


print(t.test(all_edge_distances, all_pairwise_distances, paired=FALSE))
print(wilcox.test(all_edge_distances, all_pairwise_distances, paired=FALSE))
