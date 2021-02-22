#!/usr/bin/Rscript
##
## File:    makeTriadCensusFigure.R
## Author:  Alex Stivala
## Created: August 2020
##
## Make triad census figure by using igraph to plot all 16 isomorphism
## classes of 3 nodes (directed network).
##
## Usage: Rscript makeTriadCensusFigure.R
##
## Writes output file to triad_census_figure.eps in cwd (WARNING: overwrites).
##
##

library(igraph)

## standard ordering of triad census
triadnames <- c('003', '012', '102', '021D', '021U', '021C', '111D',
                '111U', '030T', '030C', '201', '120D', '120U', '120C',
                '210', '300')
stopifnot(length(triadnames) == 16)


## isomorphism classes for 3-node directed networks numbered in igraph 0 to 15
## NB this is NOT the standard ordering of the triad census as used
## in igraph triad.census() for example; had to manually order these
## according to manual inspection of each of the results of
## graph_from_isoorphism_class()
## (used igraph version 1.2.4 in R version 3.5.2).
## So we need to map them to the orering above
map <- c(
  0,  #'003'
  1,  #'012'
  3,  #'102'
  6,  #'021D'
  2,  #'021U'
  4,  #'021C'
  5,  #'111D'
  9,  #'111U'
  7,  #'030T'
  11, #'030C'
  10, #'201'
  8,  #'120D'
  13, #'120U'
  12, #'120C'
  14, #'210'
  15  #'300'
)

stopifnot(length(map) == 16)
stopifnot(length(unique(map)) == 16)

## get layout from a connected graph and save to use same layout for all
set.seed(0)
layout = layout.fruchterman.reingold(graph.full(3))
###layout = layout.gem(graph.full(3))
###layout = layout_nicely(graph.full(3))

postscript("triad_census_figure.eps", horizontal=FALSE)
par(mfrow=c(4,4))
par(cex.main = 2)
for (i in 1:length(triadnames)) {
  print(triadnames[i])
  M <- substr(triadnames[i], 1, 1)
  A <- substr(triadnames[i], 2, 2)
  N <- substr(triadnames[i], 3, 3)
  g <- graph_from_isomorphism_class(size = 3,
                                    number = map[i] , directed = TRUE)
  dyads <- dyad.census(g)
  print(dyads)
  stopifnot(dyads$mut == M)
  stopifnot(dyads$asym == A)
  stopifnot(dyads$null == N)
  plot(g,
       layout = layout,
       main = triadnames[i],
       vertex.label = NA,
       vertex.size = 50,
       edge.color = 'black',
       vertex.color = 'red',
       )
}
dev.off()

