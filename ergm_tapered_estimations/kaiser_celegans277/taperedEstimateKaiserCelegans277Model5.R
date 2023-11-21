#!/usr/bin/env Rscript
###
### File:    taperedEstimateKaiserCelegans277Model5.R
### Author:  Alex Stivala
### Created: November 2023
###
### Estimating ERGM parameters for a model for the Kaiser C. elegans 
### 277 node neural network data, using tapered ERGM.
###
### Citations for data:
###
###  Varier S, Kaiser M (2011) Neural development features:
###  Spatio-temporal developme nt of the C. elegans neuronal
###  network. PLoS Computational Biology 7:e1001044 (PD F)
###
###  Kaiser M, Hilgetag CC (2006) Non-Optimal Component Placement, but
###  Short Processing Paths, due to Long-Distance Projections in Neural
###  Systems. PLoS Computational Biology 2:e95 (PDF) 
###
###  Choe Y, McCormick BH, Koh W (2004) Network connectivity analysis on
###  the temporally augmented C. elegans web: A pilot study. Society of
###  Neuroscience Abstracts 30:921.9.
###
### Usage: taperedEstimateKaiserCelegans277Model5.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'celegans277_tapered_model5.txt'
###   'celegans277_tapered_model5_mcmcdiagnostics.eps'
###   'celegans277_tapered_model5_gof.eps'
###   'model5.RData'
### WARNING: overwrites output files if they exist
###


source("load_celegans_277_data.R")
dat <- load_celegans_277_data()
g <- dat$g
celegans277_distmatrix <- dat$celegans277_distmatrix


options(scipen=9999) # force decimals not scientific notation

## Get birthtime just as a vector directly from nodes so it lines up
birthtime <- V(g)$birthtime

## Now can load statnet etc. that we have done with igraph
library(intergraph)
library(statnet)
library(ergm.tapered)

sessionInfo()

gn <- asNetwork(g)


## "MCMLE estimation did not converge after 10 iterations."
system.time ( model5 <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + ttriple + twopath + edgecov(celegans277_distmatrix)  + nodecov('birthtime'), taper.terms = "dependent", fixed = FALSE) )

print(model5)
summary(model5)

postscript('celegans277_tapered_model5_mcmcdiagnostics.eps')
mcmc.diagnostics(model5)
dev.off()

sink('celegans277_tapered_model5.txt')
print( summary(model5) )
sink()

save(gn, mode1, file = "model5.RData")

system.time( model5_gof <- gof(model5  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model)  )
print(model5_gof)
postscript('celegans277_tapered_model5_gof.eps')
par(mfrow=c(4,2))
plot( model5_gof, plotlogodds=TRUE)
dev.off()

warnings()


