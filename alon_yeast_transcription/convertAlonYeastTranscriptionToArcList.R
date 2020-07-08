#!/usr/bin/Rscript
#
# File:    convertAlonYeastTranscriptionToArcList.R
# Author:  Alex Stivala
# Created: April 2019
#
# Read the yeatInter_st.txt file downloaded from 
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
#    yeast_transcription_arclist.txt         - arc list Pajek format
#
#

library(igraph)


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertAlontYeastTranscriptionToArcList.R\n")
  quit(save="no")
}

yeastinter <- read.table("yeastinter_st.txt", header = FALSE)

# from yeastreadme.doc:
#
#   yeastInter_st.txt is a text file that includes all the interactions
#   in the network. The convention used in the file is that the order of
#   the columns is: regulating gene (TF), regulated gene, mode of
#   regulation.  In the basic yeastInter.txt network the mode of
#   regulation is always 1, we did not differentiate between activators
#   and repressors. See below for information on datasets that include the
#   mode of regulation.

yeastinter$V3 <- NULL # drop 3rd column (always 1 for regulation mode)
g <- graph.edgelist(as.matrix(yeastinter))

summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

network_name <- "yeast_transcription"
arclistfilename <- paste(network_name, "_arclist.txt", sep="")

write.graph(g, arclistfilename, format="pajek")
 
