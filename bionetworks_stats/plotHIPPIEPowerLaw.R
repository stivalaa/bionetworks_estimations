#!/usr/bin/Rscript
#
# File:    plotHIPPIEpowerLaw.R
# Author:  Alex Stivala
# Created: June 2021
#
# Plot power law and log-normal fit to biological networks degree distribution,
# using the poweRlaw package (Gillespie 2015 J. Stat. Soft)
#
# Usage: Rscript ploHIPPIEpowerLaw.R 
#
# Network file locations are hardcoded here.
# Writes output to hippie_powerlaw.eps (WARNING: overwrites)
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
    "../undirected/hippie/model1/hippie_ppi_high_edgelist.txt"
    )

# description of graph must line up with filename pattern above
descrs <- c(
    "Human PPI (HIPPIE)"
    )



args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 0) {
  cat("Usage: plotUndirectedPowerLaw\n")
  quit(save="no")
}
datadir <- args[1]

outfile <- "hippie_powerlaw.eps"
postscript(outfile, onefile=FALSE,
           paper="special", horizontal=FALSE, width=9, height=6)
#postscript(outfile, paper="special", horizontal=FALSE, width=9, height=6)
par(mfrow=c(length(graphs), 1))
for (i in 1:length(graphs)) {
  cat(graphs[i])
  cat('\n')

  if (grepl("\\.graphml$", graphs[i])) {
      g <- read.graph(graphs[i], format="graphml")
      g <- as.undirected(g) # only for mouse retina
  } else {
      g <- read.graph(graphs[i], format="pajek")
  }
  g <- simplify(g)


  plot_power_law(g, descrs[i], directed=FALSE)
  cat('\n')
  cat('\n')
}
dev.off()


