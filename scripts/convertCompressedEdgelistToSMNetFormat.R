#!/usr/bin/Rscript
#
# File:    convertCompressedEdgelistToSMNetFormat.R
# Author:  Alex Stivala
# Created: November 2016
#
# Read compressed (gzip) edge list file (0 based identifiers) and convert
# to files for SMNet edge list input format.
#
# The graph may be directed or undirected. 
#
# Usage:
#
# Rscript convertCompressedEdgelistToSMNetFormat.R  [-d] inputfilename
#
#    [-d] if specified, directed else undirected
#   inputfilename is name of gzipped text file with edge list.
#
# Output files (WARNING overwritten)
#    <basename>_interactome_edgelist.txt         - edge list Pajek format
#    <basename>_interactome_zones.txt            - snowball sample zones (all 0 full network)
#    <basename>_interactome_actors.txt           - node attributes
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
# main
#

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 1 || length(args) > 2) {
  cat("Usage: convertCompressedEdgelistToSMNetFormat.R [-d] inputedgelist.gz\n")
  quit(save="no")
}
basearg <- 0
directed <- FALSE
if (length(args) == 2) {
    if (args[1] == "-d") {
        directed <- TRUE
        basearg <- 1
    } else {
        cat("Usage: convertCompressedEdgelistToSMNetFormat.R  [-d] inputedgelist.gz\n")
        quit(save="no")
    }
}
inputfilename <- args[basearg+1]
basefilename <- sub("(.+)[.].+[.]gz", "\\1", basename(inputfilename))

if (directed) {
  cat("directed\n")
} else { 
  cat("undirected\n")
}

D<-read.table(gzfile(inputfilename))
g <- graph.edgelist(as.matrix(D)+1, directed=directed) # add 1 for 0-based input
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)

network_name <- basefilename
zonefilename <- paste(network_name, "_zones.txt", sep="")
edgelistfilename <- paste(network_name, "_edgelist.txt", sep="")
actorsfilename <- paste(network_name, "_actors.txt", sep="")

write.graph(g, edgelistfilename, format="pajek")

cat(vcount(g), zonefilename, edgelistfilename, actorsfilename,
    file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file(zonefilename, rep.int(0, vcount(g)))
write.graph(g, edgelistfilename, format="pajek")
write_subactors_file(actorsfilename, g)


