#!/usr/bin/Rscript
#
# File:    plotSMNetStats.R
# Author:  Alex Stivala
# Created: November 2016
#
# Plot add/del stats vs iteration 
# for Max's adapative MCMC algorhtm output RD? files.
#
#
# Usage: Rscript plotSMNetStats.R 
#
# Output is PDF file parameters.pdf 
#
library(grid)
library(gridExtra)
library(ggplot2)
library(reshape)
library(doBy)

zSigma <- 1.96 # number of standard deviations for 95% confidence interval

outfilename <- 'rd_stats.pdf'

RD <- NULL
for (pdfile in Sys.glob("RD[0-9]*")) {
  run <- as.integer(sub("RD([0-9]+)", "\\1", pdfile))
  RDrun <- read.table(pdfile)
  RDrun$run <- run
  RD <- rbind(RD, RDrun)
}
RDnames <- read.table('RD_names', stringsAsFactors=FALSE)
names(RD) <- c(RDnames, "run")
RD$run <- as.factor(RD$run)
idvars <- c('run', 'Iteration')
paramnames <- names(RD)[which(!(names(RD) %in% idvars))]
RD <- melt(RD, id=idvars)
plotlist <- list()
for (paramname in paramnames) {
    RDv <- RD[which(RD$variable == paramname),]
    p <- ggplot(RDv, aes(x=Iteration, y=value, colour=run))
    RDsum <- summaryBy(value ~ paramname        , data=RDv[which(RDv$Iteration > 200),], FUN=c(mean, sd)) # mean for iterations past 200
print (RDsum)#XXX
    p <- p + geom_point(alpha=1/4)
    p <- p + geom_hline(yintercept=RDsum$value.mean)
    p <- p + geom_hline(yintercept=RDsum$value.mean + zSigma*RDsum$value.sd, linetype='longdash')
    p <- p + geom_hline(yintercept=RDsum$value.mean - zSigma*RDsum$value.sd, linetype='longdash')
    p <- p + xlab('Iteration')
    p <- p + ylab(paramname)
    p <- p + guides(colour = guide_legend(override.aes = list(alpha=1)))
    plotlist <- c(plotlist, list(p))
    cat(paramname, 'mean/sd =', RDsum$value.mean / RDsum$value.sd, '\n', sep=' ')
}

# use PDF for transparancy (alpha) not supported by postscript
pdf(outfilename, onefile=FALSE,
           paper="special", width=9, height=6)
do.call(grid.arrange, plotlist)
dev.off()

