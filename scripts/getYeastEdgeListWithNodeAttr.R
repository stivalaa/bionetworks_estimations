#!/usr/bin/Rscript
#
# File:    getYeastEdgeListWithAttr.R
# Author:  Alex Stivala
# Created: November 2016
#
#
# Get yeast protein interaction network from Nexus and wrte files for
# SMNet estimation with node attributes.
# Ref for network from Nexus is:
#
#   Christian von Mering, Roland Krause, Berend Snel, Michael Cornell, 
#   Stephen G. Oliver, Stanley Fields & Peer Bork, Comparative assessment 
#   of large-scale data sets of protein.protein interactions, 
#   Nature 417, 399-403 (2002)
#
# Usage:
# 
# Rscript getYeastEdgeListWithAttr.R 
#
# Output files are (WARNING: overwritten in cwd):
#
#    sampledesc.txt		- referred to in setting.txt, names other files
#    yeast_edgelist.txt          - edge list Pajek format
#    yeast_zones.txt            - snowball sample zones (all 0 full network)
#    yeast_actors.txt           - node attributes
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
  # TODO specific to yeast data, make this a reusable function and put in
  # snowballSample.R

  num_bin_attr = 0  
  num_cont_attr = 0
  num_cat_attr = 1  # Class 
  f <- file(filename, open="wt")
  cat("* Actors ", vcount(g), "\n", file=f)
  cat("* Number of Binary Attributes = ", num_bin_attr, "\n", file=f)
  cat("* Number of Continuous Attributes = ", num_cont_attr, "\n", file=f)
  cat("* Number of Categorical Attributes = ", num_cat_attr, "\n", file=f)
  cat("Binary Attributes:\n", file=f)
  #cat("id Manager\n", file=f) 
  cat("id\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_bin_attr) {
      cat (" ", file=f)
#      cat((if (V(g)$Manager[i] == "Y") "1" else "0"), file=f)
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
  cat("id class\n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_cat_attr) {
      cat (" ", file=f)
      # output cat attr j value for node i
      if (j == 1) {
        cat(V(g)$class_cat[i], file=f)
      } 
      else {
        stop(paste("unknown attribute j = ", j))
      }
    }
    cat("\n", file=f)
  }
  close(f)
}


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: getYeastEdgeListWithAttr.R\n")
  quit(save="no")
}

g <- nexus.get("yeast")
summary(g)
stopifnot(vcount(g) == 2617)
stopifnot(ecount(g) == 11855 )

g <- simplify(g, remove.multiple = TRUE, remove.loops = TRUE)
stopifnot(vcount(g) == 2617)
stopifnot(ecount(g) == 11855 )

summary(g)
# write vertex names/attributes for future ref (save stdout to file to keep)
print(V(g)$name)
print(V(g)$Class)

# convert NA Class to "U" (uncharacterized)
# [not sure why there is both "U" and NA]
V(g)$Class[which(is.na(V(g)$Class))] <- "U"

# convert class to integer for categorical attribute
V(g)$class_cat <- unclass(factor(V(g)$Class))

# write vertex attributes for future ref (save stdout to file to keep)
print(V(g)$Class)
print(V(g)$class_cat)


cat(vcount(g), "yeast_zones.txt", "yeast_edgelist.txt", "yeast_actors.txt", file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file("yeast_zones.txt", rep.int(0, vcount(g)))
write.graph(g, "yeast_edgelist.txt", format="pajek")
write_subactors_file_with_attr("yeast_actors.txt", g)


