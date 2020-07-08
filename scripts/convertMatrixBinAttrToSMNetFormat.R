#!/usr/bin/Rscript
#
# File:    convertMatrixBinAttrToSMNetFormat.R
# Author:  Alex Stivala
# Created: November 2016
#
#
# Read PNet adjacency matrix network and binary attributes and conver to format
# for SMNet estimation with binary node attributes.
# Ref for network from Nexus is:
#
# Usage:
# 
# Rscript convertMatrixBinAttrToSMNetFormat.R networkfile binattrfile
#
# Output files are (WARNING: overwritten in cwd):
#
#    sampledesc.txt		- referred to in setting.txt, names other files
#    edgelist.txt          - edge list Pajek format
#    zones.txt            - snowball sample zones (all 0 full network)
#    actors.txt           - node attributes
#

library(igraph)

# read in R source file from directory where this script is located
#http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
source_local <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
  source(paste(base_dir, fname, sep=.Platform$file.sep))
}

source_local('snowballSample.R')

# 
# write_subactors_file_with_attr() - write subacctors file in parallel spnet format
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
write_subactors_file_with_attr <- function(filename, g) {
  # TODO specific to binattr data, make this a reusable function and put in
  # snowballSample.R

  num_bin_attr = 1  
  num_cont_attr = 0
  num_cat_attr = 0
  f <- file(filename, open="wt")
  cat("* Actors ", vcount(g), "\n", file=f)
  cat("* Number of Binary Attributes = ", num_bin_attr, "\n", file=f)
  cat("* Number of Continuous Attributes = ", num_cont_attr, "\n", file=f)
  cat("* Number of Categorical Attributes = ", num_cat_attr, "\n", file=f)
  cat("Binary Attributes:\n", file=f)
  cat("id binaryAttribute\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_bin_attr) {
      cat (" ", file=f)
      cat(V(g)$binaryAttribute[i], file=f)
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

#
# main
#

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  cat("Usage: convertMatrixBinAttrToSMNetFormat.R matrixfile binattrfile\n")
  quit(save="no")
}
matrixfile <- args[1]
binattrfile <- args[2]

g <- read_graph_file(matrixfile, directed=FALSE)
binattrs <- read.table(binattrfile, header=TRUE)
V(g)$binaryAttribute <- binattrs$binaryAttribute
summary(g)

cat(vcount(g), "zones.txt", "edgelist.txt", "actors.txt", file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file("zones.txt", rep.int(0, vcount(g)))
write.graph(g, "edgelist.txt", format="pajek")
write_subactors_file_with_attr("actors.txt", g)

