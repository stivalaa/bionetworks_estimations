#!/usr/bin/Rscript
#
# File:    plotUndirectedPowerLawSubset.R
# Author:  Alex Stivala
# Created: September 2021
#
# Plot power law and log-normal fit to biological networks degree distribution,
# using the poweRlaw package (Gillespie 2015 J. Stat. Soft)
# for a subset of the undireted networks
#
# Usage: Rscript plotUndirectedPowerLawsubset.R 
#
# Network file locations are hardcoded here.
# Writes output to directed_bionetworks_powerlaw_subset.eps (WARNING: overwrites)
# and p-values etc. to stdout
#


# read in R source file from directory where this script is located
#http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
source_local <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
  source(paste(base_dir, fname, sep=.Platform$file.sep))
}

source_local('plotPowerLaw.R')


graphs <- c(
    "../undirected/yeast/model1/yeast_edgelist.txt",
    "../undirected/hippie/model1/hippie_ppi_high_edgelist.txt"
    )

# description of graph must line up with filename pattern above
descrs <- c(
    "Yeast PPI",
    "Human PPI (HIPPIE)"
    )



args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 0) {
  cat("Usage: plotUndirectedPowerLaw\n")
  quit(save="no")
}
datadir <- args[1]

outfile <- "undirected_bionetworks_powerlaw_subset.eps"
postscript(outfile, onefile=FALSE,
           paper="special", horizontal=FALSE, width=9, height=6)
#postscript(outfile, paper="special", horizontal=FALSE, width=9, height=6)
par(mfrow=c(1, 2))
for (i in 1:length(graphs)) {
  cat(graphs[i])
  cat('\n')
  g <- read.graph(graphs[i], format="pajek")
  g <- simplify(g)


  plot_power_law(g, descrs[i], directed=FALSE)
  cat('\n')
  cat('\n')
}
dev.off()


