#!/usr/bin/Rscript
#
# File:    convertGMLToSMNetFormat.R
# Author:  Alex Stivala
# Created: August 2017
#
# Read GML file (0 based identifiers) and convert
# to files for SMNet edge list input format,
# with single binary node attribute.
#
# The graph may be directed or undirected. 
#
# Usage:
#
# Rscript convertGMLToSMNetFormat.R  inputfilename
#
#   inputfilename is name of GML file
#
# Output files (WARNING overwritten)
#    <basename>_edgelist.txt         - edge list Pajek format
#    <basename>_zones.txt            - snowball sample zones (all 0 full network)
#    <basename>_actors.txt           - node attributes
#    sampledesc.txt                   - index to above files
#
# where <basenane> is basename of inputfilename.
#

library(gdata)  # for reading .xls file
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
  cat("id Attribute1\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_bin_attr) {
      cat (" ", file=f)
      cat((if (V(g)$binattr[i] == 1) "1" else "0"), file=f)
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
#  cat("id Value\n", file=f)
  cat("id \n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_cat_attr) {
#      cat (" ", file=f)
#      # output cat attr j value for node i
#      if (j == 1) {
#        cat(as.numeric(V(g)$value[i]), file=f)
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
if (length(args) < 1 || length(args) > 2) {
  cat("Usage: convertGMLToSMNetFormat.R [-d] inputedgelist.gz\n")
  quit(save="no")
}
basearg <- 0
inputfilename <- args[basearg+1]
basefilename <- sub("(.+)[.]gml", "\\1", basename(inputfilename))
gmlfilename <- inputfilename

cat("loading data from ", gmlfilename, "...\n")
print(system.time(g <- read.graph(gmlfilename, format="gml")))
print(g)
print(system.time(g <- simplify(g)))
print(g)

# remove special igraph node id/name attribute
# to stop getting node names in output
#g <- delete.vertex.attr(g, "id")
g <- remove.vertex.attribute(g, "id")

if (is.directed(g)) {
  cat("directed\n")
} else { 
  cat("undirected\n")
}

network_name <- basefilename
zonefilename <- paste(network_name, "_zones.txt", sep="")
edgelistfilename <- paste(network_name, "_edgelist.txt", sep="")
actorsfilename <- paste(network_name, "_actors.txt", sep="")


cat(vcount(g), zonefilename, edgelistfilename, actorsfilename,
    file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file(zonefilename, rep.int(0, vcount(g)))
write.graph(g, edgelistfilename, format="pajek")
write_subactors_file_with_attr(actorsfilename, g)


