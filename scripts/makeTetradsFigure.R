#!/usr/bin/Rscript
##
## File:    makeTetradsFigure.R
## Author:  Alex Stivala
## Created: September 2021
##
## Make tetrad census figure by using NetMODE interface to plot
## the graphs corresponding to the 4 node motif identifiers we use
## (directed network).
##
## Usage: Rscript makeTetradsFigure.R
##
## Writes output file to tetrads_figure.eps in cwd (WARNING: overwrites).
##
## Citation for NetMODE is:
##   Li, X., Stones, R. J., Wang, H., Deng, H., Liu, X., & Wang, G. (2012).
##   NetMODE: Network motif detection without nauty. PloS One, 7(12), e50093.
##
## and is available from:
##  https://sourceforge.net/projects/netmode/files/NetMODE%201.04/
##
## Uses the NetMODE R interface which in turn
## uses the igraph library:
##
##   Csardi G, Nepusz T: The igraph software package for complex network
##   research, InterJournal, Complex Systems
##   1695. 2006. http://igraph.org
##
##
## This paper was useful to find MFinder ids (as also used in e.g. NetMODE) 
## of 4-node motifs (not even all the
## common ones e.g. bi-parallel seem to be in the MFinder motif dictionary
## PDF file):
## 
##   Tran, N. T. L., DeLuccia, L., McDonald, A. F., & Huang, C. H. (2015). 
##   Cross-disciplinary detection and analysis of network motifs.
##   Bioinformatics and Biology insights, 9, BBI-S23619.
## 


library(igraph)
## See NetMODE.R for desciprtion of R interface
source("/home/stivala/NetMODE104/NetMODE.R")

tetrad_ids <- c(204, 2182)
## lines up with tetrad_ids
tetrad_names <- c("Bi-fan", "Bi-parallel")
stopifnot(length(tetrad_names) == length(tetrad_ids))



set.seed(0)

postscript("tetrads_figure.eps", horizontal=FALSE)
par(mfrow=c(1,2))
par(cex.main = 2)
for (i in 1:length(tetrad_ids)) {
  print(tetrad_ids[i])
  print(tetrad_names[i])
  g <- GraphIDToGraph(k=4, ID=tetrad_ids[i])
  plot(g,
       layout = layout.gem,
       vertex.label = NA,
       vertex.size = 50,
       edge.color = 'black',
       vertex.color = 'red',

       )
  title(main = tetrad_names[i], line = -12, font.main = 1) # https://stackoverflow.com/questions/20355410/adjust-plot-title-main-position/20355606
}
dev.off()

