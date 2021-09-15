#!/usr/bin/Rscript
#
# File:    plotCombinedBioNetworksPowerLawSubset.R
# Author:  Alex Stivala
# Created: September 2021
#
# Plot power law and log-normal fit to biological networks degree distribution,
# using the poweRlaw package (Gillespie 2015 J. Stat. Soft)
# This version does directed and undirected (subset, just those used in paper)
# combined on same plot.
#
# Usage: Rscript plotCombinedBioNetworksPowerLaw.R 
#
# Network file locations are hardcoded here.
# Writes output to combined_bionetworks_powerlaw_subset.eps (WARNING: overwrites)
#


# read in R source file from directory where this script is located
#http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
source_local <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
  source(paste(base_dir, fname, sep=.Platform$file.sep))
}

source_local('plotPowerLaw.R')

directed_graphs <- c(
    "../ecoli/estimnetdirected/ecoli1_arclist.txt",
    "../alon_yeast_transcription/yeast_transcription_arclist.txt"
    )

# description of graph must line up with filename pattern above
directed_descrs <- c(
    expression('Alon'~~italic('E. coli')~~'regulatory'),
    expression('Alon yeast regulatory')
    )


undirected_graphs <- c(
    "../undirected/yeast/model1/yeast_edgelist.txt",
    "../undirected/hippie/model1/hippie_ppi_high_edgelist.txt"
    )

# description of graph must line up with filename pattern above
undirected_descrs <- c(
    expression("Yeast PPI"),
    expression("Human PPI (HIPPIE)")
    )


args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 0) {
  cat("Usage: Rscript plotCombinedBioNetworksPowerLawSubset.R\n")
  quit(save="no")
}
datadir <- args[1]

##outfile <- "combined_bionetworks_powerlaw_subset.pdf"
### use PDF as journal only allows PDF not EPS
##pdf(outfile, onefile=FALSE,
##           paper="special", width=9, height=6)
# actually, use .eps and convert to .pdf later as arXiv requires .eps
outfile <- "combined_bionetworks_powerlaw_subset.eps"
postscript(outfile, onefile=FALSE, horizontal = FALSE,
           paper="special", width=9, height=6)
#par(mfrow=c(length(graphs), 2))
#par(mar=c(2,2,2,2)) # https://stackoverflow.com/questions/23050928/error-in-plot-new-figure-margins-too-large-scatter-plot
par(mfrow=c(2,3))
for (i in 1:length(directed_graphs)) {
  cat(directed_graphs[i])
  cat('\n')
  g <- read.graph(directed_graphs[i], format="pajek")
  plot_power_law(g, directed_descrs[i], directed=TRUE, useoutdegree=FALSE, compute_pvalue=FALSE )
  cat('\n')
  plot_power_law(g, directed_descrs[i], directed=TRUE, useoutdegree=TRUE, compute_pvalue=FALSE )
  cat('\n')
  cat('\n')
}
for (i in 1:length(undirected_graphs)) {
  cat(undirected_graphs[i])
  cat('\n')
  g <- read.graph(undirected_graphs[i], format="pajek")
  g <- simplify(g)


  plot_power_law(g, undirected_descrs[i], directed=FALSE, compute_pvalue=FALSE)
  cat('\n')
  cat('\n')
}
dev.off()


