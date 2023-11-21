#!/usr/bin/Rscript
#
# File:    plotNeuralPowerLaw.R
# Author:  Alex Stivala
# Created: November 2023
#
# Plot power law and log-normal fit to biological networks degree distribution,
# using the poweRlaw package (Gillespie 2015 J. Stat. Soft)
#
# Usage: Rscript plotNeuralPowerLaw.R 
#
# Network file locations are hardcoded here.
# Writes output to neural_bionetworks_powerlaws.eps (WARNING: overwrites)
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
  "../cook_celegans/CelegansMaleChem/GMaleChem_arclist.txt",
  "../lolog_estimations/kaiser_celegans277/celegans277.net",
    "../ergm_tapered_estimations/fly_medulla/drosophila_medulla_1_named_arclist.txt"
    )

# description of graph must line up with filename pattern above
descrs <- c(
  expression(Cook~italic('C. elegans')~~'connectome'),
  expression(Kaiser~~italic('C. elegans')~~'neural'),
  expression(italic('Drosophila')~~'medulla (named)')
    )



args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 0) {
  cat("Usage: plotNeuralPowerLaw\n")
  quit(save="no")
}
datadir <- args[1]

outfile <- "neural_bionetworks_powerlaws.eps"
postscript(outfile, onefile=FALSE,
           paper="special", horizontal=FALSE, width=9, height=6)
#postscript(outfile, paper="special", horizontal=FALSE, width=9, height=6)
par(mfrow=c(length(graphs), 2))
# Finally got this to work showing title and x label caption (as usual with R, took lots of tedious trial and error until it worked):
par(mar=c(4, 2, 3, 1.5)) # https://stackoverflow.com/questions/23050928/error-in-plot-new-figure-margins-too-large-scatter-plot
for (i in 1:length(graphs)) {
  cat(graphs[i])
  cat('\n')
  g <- read.graph(graphs[i], format="pajek")
  plot_power_law(g, descrs[i], directed=TRUE, useoutdegree=FALSE )
  cat('\n')
  plot_power_law(g, descrs[i], directed=TRUE, useoutdegree=TRUE )
  cat('\n')
  cat('\n')
}
dev.off()


