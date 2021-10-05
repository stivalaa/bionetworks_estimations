#!/usr/bin/Rscript
#
# File:    convertAlonYeastTranscriptionToArcList.R
# Author:  Alex Stivala
# Created: September 2021
#
# Read the yeastData.mat file downloaded from 
# http://www.weizmann.ac.il/mcb/UriAlon/download/collection-complex-networks
# and write Pajek arc list format.
#
# Citation for data is
#
#   Milo, R., Shen-Orr, S., Itzkovitz, S., Kashtan, N., 
#   Chklovskii, D., & Alon, U. (2002). Network motifs: simple building blocks 
#   of complex networks. Science, 298(5594), 824-827.
#
#
# 
# Rscript convertALonYeastTranscriptionToArcList.R 
#
# Output files (WARNING overwritten)
#    yeast_arclist_loops.txt
#    yeast_arclist_noloops.txt
#    yeast_names.txt
#
#
# Note we are using yeastData.mat here not yeastInter_st.txt, and it seems
# they are not exactly the same, for example the latter has 690 nodes
# but the former only 688

library(igraph)
library(R.matlab)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertAlontYeastTranscriptionToArcListWithLoops.R\n")
  quit(save="no")
}

dat <- readMat('yeastdata.mat')

# from yeastreadme.doc:
#
#  The conversion between node indexes and gene names can be found in the yeastData.mat file. 
#  yeastData.mat is a matlab file, and to open it you should use Matlab. The file is actually a workspace of several variables/datasets as follows:
#  im is the complete interaction matrix including auto-regulations and with signs for the regulation 1=activator 2=repressor 3=dual regulation. the names of the nodes are at namesWNull.
#  imnd refers to the interaction matrix with the auto regulations that are located on the diagonal of the matrix being omitted (nd - NoDiagonal)
#  after taking the diagonal off sometimes there is no other interaction at all for that node and it is therefore a null. imnn omits these null (nn - NoNull)
#  im1 is with all interactions being represented as 1 without reference to the type of regulation, and again with no nulls. The names are at the variable called names.
#  Usually we use the im1 for most applications.
#  It is possible by using the names to find the genes participating in any of the motifs using the motif detection tool - mfinder

g <- graph_from_adjacency_matrix(t(as.matrix(dat$im1)))
V(g)$names <- unlist(dat$names)

summary(g)
cat("Number of loops: ", sum(which_loop(g)), "\n")

summary(simplify(g))

write.table(V(g)$names, "yeast_names.txt", col.names=F,row.names=F, quote=F)
write.graph(g, 'yeast_arclist_loops.txt', format='pajek')
write.graph(simplify(g), 'yeast_arclist_noloops.txt', format='pajek')

