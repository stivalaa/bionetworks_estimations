#!/usr/bin/Rscript
#
# File:    computeSMNetPLOTN.R
# Author:  Alex Stivala
# Created: April 2018
#
# Compute estimate from PD* files output in the PLOTN directory hierarchy
#
# Usage: Rscript computeSMNetPLOTN.R <pdfilename>
# e.g. 
# Usage: Rscript computeSMNetPLOTN.R ~/PLOTN/1000AS/PD0
#

library(doBy)
library(reshape2)


args <- commandArgs(trailingOnly=TRUE)
pdfile <- args[1]
estdir <- dirname(pdfile)

# First iteration number to use, to skip over initial burn-in
firstiter = 200 # skip first 200 iterations. FIXME some way to determine properly

# subsample along chains, i.e. take only every x'th 
# iteration for some x, to avoid autocorrelated samples
period = 50 # take every 50th sample

# Tables have parameter or statistics for each iteration of each run
idvars <- c('Iteration')

# get parameter estimates from PD files
PD <- read.table(pdfile)

PDnames <- read.table(paste(estdir, 'PD_names', sep='/'),  stringsAsFactors=FALSE)
PDnames <- PDnames[which(PDnames != "Edge")] # PLOTN results have no Edge parameter even though in names
names(PD) <- c(PDnames)
paramnames <- names(PD)[which(!(names(PD) %in% idvars))]
PD <- melt(PD, id=idvars)


for (paramname in paramnames) {
    PDv <- PD[which(PD$variable == paramname),]
    PDv <- PDv[which(PDv$Iteration >= firstiter),]
    PDv <- PDv[which(PDv$Iteration %% period == 0),]
    PDsum <- summaryBy(value ~ paramname, data=PDv, FUN=c(mean, sd))

    cat(paramname, PDsum$value.mean, PDsum$value.sd, '\n')
}
