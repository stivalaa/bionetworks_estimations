#!/usr/bin/env Rscript
###
### File:    tapered_GMaleChem_model2.R
### Author:  Alex Stivala
### Created: May 2023
###
### Estimating ERGM parameters for a model for 
### C. elegans whole connectome (male, chemical [directed]) from 
###
### Citation for data is:
###
###  Cook, S. J., Jarrell, T. A., Brittin, C. A., Wang, Y., Bloniarz, 
###  A. E., Yakovlev, M. A., ... & Emmons, S. W. (2019).
###  Whole-animal connectomes of both Caenorhabditis elegans sexes.
###  Nature, 571(7763), 63-71.
###
### Usage: Rscript tapered_GMaleChem_model2.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'GMaleChem_tapered_model2.txt'
###   'GMaleChem_tapered_model2_mcmcdiagnostics.eps'
###   'GMaleChem_tapered_model2_gof.eps'
###    model2.RData
### WARNING: overwrites output files if they exist
###
###

library(igraph)
library(intergraph)
library(ergm.tapered)


options(scipen=9999) # force decimals not scientific notation

g <- read.graph('GMaleChem_arclist.txt', format='pajek')
summary(g)
gn  <- asNetwork(g)

# good convergence, but bad gof on esp, dsp, geodesic (especially) [ 7 hours ]
system.time(model2  <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + ttriple + gwdsp(1.0, fixed=TRUE), taper.terms = "dependent", fixed = FALSE, control = control.ergm.tapered(MCMLE.maxit = 120)))

# Converges OK, bad GoF on esp, geodesic (especialy geodesic) [ 5 hours ]
#system.time(model2  <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + ttriple + gwdsp(0.0, fixed=TRUE), taper.terms = "dependent", fixed = FALSE))

# Does not converge:
#system.time(model2  <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + ttriple + gwdsp, taper.terms = "dependent", fixed = FALSE))

print(model2)
summary(model2)

postscript('GMaleChem_tapered_model2_mcmcdiagnostics.eps')
mcmc.diagnostics(model2)
dev.off()

sink('GMaleChem_tapered_model2.txt')
print( summary(model2) )
sink()

save(gn, model2, file = "model2.RData")

system.time( model2_gof <-  gof(model2, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model ) )
print(model2_gof)
postscript('GMaleChem_tapered_model2_gof.eps')
par(mfrow=c(4,2))
plot( model2_gof, plotlogodds=TRUE)
dev.off()

warnings()

