#!/usr/bin/Rscript
#
# File:    computeSMNetCovariance.R
# Author:  Alex Stivala
# Created: February 2017
#
# Compute covairance matrix from Max's adapative MCMC algorhtm output RD? files.
#
# Usage: Rscript computeSMNetCovariance.R 
#

library(doBy)
library(reshape2)

#zSigma <- 1.96 # number of standard deviations for 95% confidence interval     
zSigma <- 2.00 # number of standard deviations for nominal 95% confidence interval     

# First iteration number to use, to skip over initial burn-in
firstiter = 200 # skip first 200 iterations. FIXME some way to determine properly

# subsample along chains, i.e. take only every x'th 
# iteration for some x, to avoid autocorrelated samples
period = 50 # take every 50th sample

# Tables have parameter or statistics for each iteration of each run
idvars <- c('run', 'Iteration')

# get parameter estimates from PD files
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
paramnames <- names(PD)[which(!(names(PD) %in% idvars))]
PD <- melt(PD, id=idvars)

# get statistics from RD files
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
RD <- RD[which(RD$Iteration >= firstiter),]
RD <- RD[which(RD$Iteration %% period == 0),]
RD <- melt(RD, id=idvars)

# convert data frame to matrix cols params rows time/run
amatrix <- acast(RD,  run + Iteration ~ variable  , value.var='value')

# compute covariance matrix 
acov <- cov(amatrix)
acov_inv = solve(acov) # solve(A) is matrix inverse of A
#print(acov_inv)#XXX
est_stderrs <- sqrt(diag(acov_inv)) 


for (paramname in paramnames) {
    PDv <- PD[which(PD$variable == paramname),]
    PDv <- PDv[which(PDv$Iteration >= firstiter),]
    PDv <- PDv[which(PDv$Iteration %% period == 0),]
    PDsum <- summaryBy(value ~ paramname, data=PDv, FUN=c(mean, sd))

    if (paramname != "AcceptanceRate") {
      RDv <- RD[which(RD$variable == paramname),]
      RDv <- RDv[which(RDv$Iteration >= firstiter),]
      RDv <- RDv[which(RDv$Iteration %% period == 0),]
      RDsum <- summaryBy(value ~ paramname, data=RDv, FUN=c(mean, sd))
      t_ratio <- RDsum$value.mean / RDsum$value.sd
    } else {
      t_ratio <- NA
    }

    est_stderr <- est_stderrs[paramname]

    signif <- ''
    if (!is.na(t_ratio) && abs(t_ratio) <= 0.3 && abs(PDsum$value.mean) > zSigma*est_stderr) {
      signif <- '*'
    }

    cat(paramname, PDsum$value.mean, est_stderr, t_ratio, signif, '\n')
}
