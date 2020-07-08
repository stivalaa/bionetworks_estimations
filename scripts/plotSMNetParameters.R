#!/usr/bin/Rscript
#
# File:    plotSMNetParameters.R
# Author:  Alex Stivala
# Created: November 2016
#
# Plot parmaeter values vs iteration (precomputing and then computing)
# for Max's adapative MCMC algorhtm output PD? files.
#
#
# Usage: Rscript plotSMNetParameters.R 
#
# Output is PDF file parameters.pdf 
#
library(grid)
library(gridExtra)
library(ggplot2)
library(reshape)
library(doBy)

zSigma <- 1.96 # number of standard deviations for 95% confidence interval

outfilename <- 'parameters.pdf'

PD <- NULL
for (pdfile in Sys.glob("PD[0-9]*")) {
  run <- as.integer(sub("PD([0-9]+)", "\\1", pdfile))
  PDrun <- read.table(pdfile)
  PDrun$run <- run
  PD <- rbind(PD, PDrun)
}
PDnames <- read.table('PD_names', stringsAsFactors=FALSE)
names(PD) <- c(PDnames, "run")
PD$run <- as.factor(PD$run)
idvars <- c('run', 'Iteration')
paramnames <- names(PD)[which(!(names(PD) %in% idvars))]
PD <- melt(PD, id=idvars)
firstiter = 200 # XXX skip first 200 iterations
plotlist <- list()
for (paramname in paramnames) {
    PDv <- PD[which(PD$variable == paramname),]
    p <- ggplot(PDv, aes(x=Iteration, y=value, colour=run))
#    PDsum <- summaryBy(value ~ paramname,
#                  # mean over runs for last iteration only XXX,
#                        data=PDv[which(PDv$Iteration == max(PDv$Iteration)),], 
#                        FUN=c(mean, sd))
    PDsum <- summaryBy(value ~ paramname,
                        data=PDv[which(PDv$Iteration > firstiter), ],
                        FUN=c(mean, sd))

    cat(paramname, PDsum$value.mean, PDsum$value.sd, '\n')
    
    p <- p + geom_point(alpha=1/4)
    p <- p + geom_hline(yintercept=PDsum$value.mean)
    p <- p + geom_hline(yintercept=PDsum$value.mean + zSigma*PDsum$value.sd, linetype='longdash')
    p <- p + geom_hline(yintercept=PDsum$value.mean - zSigma*PDsum$value.sd, linetype='longdash')
    p <- p + xlab('Iteration')
    p <- p + ylab(paramname)
    p <- p + guides(colour = guide_legend(override.aes = list(alpha=1)))
    plotlist <- c(plotlist, list(p))
}

# use PDF for transparancy (alpha) not supported by postscript
pdf(outfilename, onefile=FALSE,
           paper="special", width=9, height=6)
do.call(grid.arrange, plotlist)
dev.off()

