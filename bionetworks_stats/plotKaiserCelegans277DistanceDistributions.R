#!/usr/bin/Rscript
#
# File:    plotKaiserCelegans277DistanceDistributions.R
# Author:  Alex Stivala
# Created: November 2023
#
# Make PostScript files plotting the distribnutions of
# 2D Euclidean distance between all directly connected nodes in the network
# and also all pairwise distances between nodes. 
# 
# Usage: Rscript plotKaiserCelegans277DistanceDistributions.R
#
# Writes output kaiser_celegans277_distance_distributions.eps to cwd
#
#
### Citations for data:
###
###  Varier S, Kaiser M (2011) Neural development features:
###  Spatio-temporal developme nt of the C. elegans neuronal
###  network. PLoS Computational Biology 7:e1001044 (PD F)
###
###  Kaiser M, Hilgetag CC (2006) Non-Optimal Component Placement, but
###  Short Processing Paths, due to Long-Distance Projections in Neural
###  Systems. PLoS Computational Biology 2:e95 (PDF) 
###
###  Choe Y, McCormick BH, Koh W (2004) Network connectivity analysis on
###  the temporally augmented C. elegans web: A pilot study. Society of
###  Neuroscience Abstracts 30:921.9.
###


library(igraph)


sessionInfo()

# Eucliean distance (2 dimensions) between two nodes
dist_between_nodes <- function(v1, v2) {
  v1point <- c(v1$x, v1$y)
  v2point <- c(v2$x, v2$y)
  return(dist(rbind(v1point, v2point)))
}

datadir <- '../lolog_estimations/kaiser_celegans277/'

celegans277adjmat <- as.matrix(read.csv(paste(datadir, 'celegans277matrix.csv', sep='/'), header=FALSE))
g <- graph_from_adjacency_matrix(celegans277adjmat)
summary(g)
g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
summary(g)

celegans277positions <- read.csv(paste(datadir, 'celegans277positions.csv', sep='/'), header=FALSE)
V(g)$x <- celegans277positions$V1
V(g)$y <- celegans277positions$V2

ug <- as.undirected(g)
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



output_postscript_filename <- 'kaiser_celegans277_distance_distributions.eps'
# for inclusion in LaTeX or epstopdf, stop it rotating it
postscript(output_postscript_filename,
           paper="special", horizontal=FALSE, width=9, height=6)
par(mfrow=c(2, 2))

# histogram
hist(all_edge_distances, xlab=("Distance (mm)"), main='Kaiser C. elegans edge distances')
abline(v = mean(all_edge_distances), col = 'blue')
# cumulative distribution, log-log plot
dtab <- table(all_edge_distances)
plot(as.numeric(names(dtab)), 1-cumsum(as.numeric(dtab)/length(dtab)),
     log='xy', xlab=expression("Distance (mm)"), ylab='CDF',
     ylim=c(0.00001,1), xlim=c(0.000230, 1.2), type='l')

# histogram
hist(all_pairwise_distances, xlab=expression("Distance (mm)"), main='Kaiser C. elegans all pairwise neuron distances')
abline(v = mean(all_pairwise_distances), col = 'blue')
# cumulative distribution, log-log plot
dtab <- table(all_pairwise_distances)
plot(as.numeric(names(dtab)), 1-cumsum(as.numeric(dtab)/length(dtab)),
     log='xy', xlab=expression("Distance (mm)"), ylab='CDF',
     ylim=c(0.00001,1), xlim=c(0.000230, 1.2), type='l')
dev.off()


print(t.test(all_edge_distances, all_pairwise_distances, paired=FALSE))
print(wilcox.test(all_edge_distances, all_pairwise_distances, paired=FALSE))
