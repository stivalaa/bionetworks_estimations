#!/usr/bin/Rscript
#
# File:    getEcol2EdgeListAndSelfLoopAttr.R
# Author:  Alex Stivala
# Created: March 2017
#
#Get the network data for the E. coli regulatory network (undircted)
#as used in Saul & Filkov 2007 and Hummel et al. 2012. The network is
#obtained from the ergm package data(ecoli) and other citations required
#are
#   Salgado et al (2001), Regulondb (version 3.2): Transcriptional
#     Regulation and Operon Organization in Escherichia Coli K-12,
#     _Nucleic Acids Research_, 29(1): 72-74.
#
#     Shen-Orr et al (2002), Network Motifs in the Transcriptional
#     Regulation Network of Escerichia Coli, _Nature Genetics_, 31(1):
#     64-68.
#
# Write in format for SMNet estimation.
# This version also gets the self-loop node attribute as a binary attribute.
#
# Usage:
# 
# Rscript getEcoli2EdgeListAndSelfLoopAttr.R 
#
# Output files (WARNING overwritten)

#    ecoli2_edgelist.txt         - edge list Pajek format
#    ecoli2_zones.txt            - snowball sample zones (all 0 full network)
#    ecoli2_actors.txt           - node attributes
#    sampledesc.txt              - index to above files
#

library(statnet)
library(intergraph)
library(igraph)

source("../../scripts/snowballSample.R")

# 
# write_subactors_file_with_bin_attr() - write subacctors file in parallel spnet format
#
# Parameters:
#     filename - filename to write to (warning: overwritten)
#     g - igrpah graph object
#
# Return value:
#    None
#
# See documetnation of this file in snowball.c readSubactorsFile()
# (format written by showActorsFile()).
#
write_subactors_file_with_bin_attr <- function(filename, g) {
  # TODO specific to ecoli2 data, make this a reusable function and put in
  # snowballSample.R

  num_bin_attr = 1   #self
  num_cont_attr = 0
  num_cat_attr = 0
  f <- file(filename, open="wt")
  cat("* Actors ", vcount(g), "\n", file=f)
  cat("* Number of Binary Attributes = ", num_bin_attr, "\n", file=f)
  cat("* Number of Continuous Attributes = ", num_cont_attr, "\n", file=f)
  cat("* Number of Categorical Attributes = ", num_cat_attr, "\n", file=f)
  cat("Binary Attributes:\n", file=f)
  cat("id self\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_bin_attr) {
      cat (" ", file=f)
      cat((if (V(g)$self[i]) "1" else "0"), file=f)
    }
    cat("\n", file=f)
  }
  cat("Continuous Attributes:\n", file=f)
  #cat("id EgonetDegree CommOnlyDegree Comments Recommendations Views BlogCmtCnt BlogCnt ForumRepCnt ForumCnt\n", file=f) 
  cat("id \n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_cont_attr) {
#      cat (" ", file=f)
#      # output cont attr j value for node i
#      value <- switch(j,
#        V(g)$EgonetDegree[i],
#        V(g)$CommOnlyDegree[i],
#        V(g)$Comments[i],
#        V(g)$Recommendations[i],
#        V(g)$Views[i],
#        V(g)$BlogCmtCnt[i],
#        V(g)$BlogCnt[i],
#        V(g)$ForumRepCnt[i],
#        V(g)$ForumCnt[i]
#      )
#      cat(value, file=f)
#    }
    cat("\n", file=f)
  }
  cat("Categorical Attributes:\n", file=f)
#  cat("id class\n", file=f)
  cat("id\n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_cat_attr) {
#      cat (" ", file=f)
#      # output cat attr j value for node i
#      if (j == 1) {
#        cat(V(g)$class_cat[i], file=f)
#      } 
#      else {
#        stop(paste("unknown attribute j = ", j))
#      }
#    }
    cat("\n", file=f)
  }
  close(f)
}


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: getEcoli2EdgeList.R\n")
  quit(save="no")
}

data(ecoli)
g <- asIgraph(ecoli2)
summary(g)


network_name <- "ecoli2"
zonefilename <- paste(network_name, "_zones.txt", sep="")
edgelistfilename <- paste(network_name, "_edgelist.txt", sep="")
actorsfilename <- paste(network_name, "_actors.txt", sep="")

write.graph(g, edgelistfilename, format="pajek")

cat(vcount(g), zonefilename, edgelistfilename, actorsfilename,
    file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file(zonefilename, rep.int(0, vcount(g)))
write.graph(g, edgelistfilename, format="pajek")
write_subactors_file_with_bin_attr(actorsfilename, g)


