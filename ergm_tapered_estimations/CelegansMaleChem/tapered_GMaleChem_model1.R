#!/usr/bin/env Rscript
###
### File:    tapered_GMaleChem_model1.R
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
### Usage: Rscript tapered_GMaleChem_model1.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'GMaleChem_tapered_model1.txt'
###   'GMaleChem_tapered_model1_mcmcdiagnostics.eps'
###   'GMaleChem_tapered_model1_gof.eps'
###    model1.RData
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

# (2.7 hours) bad gof on esp, dsp, especially bad on geodesic (ok on triad censu)
system.time(model1  <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

# (20 hours) bad gof on odegree, idegree, esp, dsp, geodesic (ok on triad census)
#system.time(model1  <- ergm.tapered(gn ~ edges + gwidegree(0.0, fixed=TRUE) + gwodegree(0.0, fixed=TRUE) + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

# Bad GoF on gwideg, gwodeg, esp, gedoesic (but good on triad census):
#system.time(model1  <- ergm.tapered(gn ~ edges + gwidegree(0.5, fixed=TRUE) + gwodegree(0.5, fixed=TRUE) + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

# Does not converge:
#system.time(model1  <- ergm.tapered(gn ~ edges + gwidegree + gwodegree + ttriple + twopath, taper.terms = "dependent", fixed = FALSE))

print(model1)
summary(model1)

postscript('GMaleChem_tapered_model1_mcmcdiagnostics.eps')
mcmc.diagnostics(model1)
dev.off()

sink('GMaleChem_tapered_model1.txt')
print( summary(model1) )
sink()

save(gn, model1, file = "model1.RData")

system.time( model1_gof <-  gof(model1, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model ) )
print(model1_gof)
postscript('GMaleChem_tapered_model1_gof.eps')
par(mfrow=c(4,2))
plot( model1_gof, plotlogodds=TRUE)
dev.off()

warnings()

