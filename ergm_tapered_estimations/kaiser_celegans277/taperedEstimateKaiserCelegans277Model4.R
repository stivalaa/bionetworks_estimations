#!/usr/bin/env Rscript
###
### File:    taperedEstimateKaiserCelegans277Model4.R
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
### Usage: taperedEstimateKaiserCelegans277Model4.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'celegans277_tapered_model4.txt'
###   'celegans277_tapered_model4_mcmcdiagnostics.eps'
###   'celegans277_tapered_model4_gof.eps'
###   'model4.RData'
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

## Note ALWAYS get error with ergm.tapered():`
##  Error in array(STATS, dims[perm]) : 'dims' cannot be of length 0
#   Calls: system.time ... ergm.tapered -> ergm.tapered -> apply -> sweep -> aperm -`
## even when it otherwise seems like it has converged, 
## i.e. it does not work at all on some installations,
## specifically e.g. ozstar (nt) even after re-installing statnet, ergm
## and ergm.tapered (multiple times, and whether ergm is 4.5.0 from CRAN
## or from github):
##  R version 4.2.1 (2022-06-23)
##  other attached packages:
##   [1] ergm.tapered_1.1-0       statnet_2019.6           tsna_0.3.5              
##   [4] sna_2.7-1                statnet.common_4.9.0-423 ergm.count_4.1.1        
##   [7] tergm_4.2.0              networkDynamic_0.11.3    ergm_4.5.0              
##  [10] network_1.18.1           intergraph_2.0-2         igraph_1.3.2            
##  
##  loaded via a namespace (and not attached):
##   [1] pillar_1.9.0            compiler_4.2.1          DEoptimR_1.0-14        
##   [4] tools_4.2.1             nlme_3.1-158            memoise_2.0.1          
##   [7] lifecycle_1.0.3         tibble_3.2.1            rle_0.9.2              
##  [10] networkLite_1.0.5       lattice_0.20-45         pkgconfig_2.0.3        
##  [13] rlang_1.1.1             Matrix_1.4-1            ergm.multi_0.2.0       
##  [16] cli_3.6.1               parallel_4.2.1          fastmap_1.1.1          
##  [19] coda_0.19-4             dplyr_1.1.2             generics_0.1.2         
##  [22] vctrs_0.6.2             tidyselect_1.2.0        trust_0.1-8            
##  [25] grid_4.2.1              glue_1.6.2              robustbase_0.95-1      
##  [28] R6_2.5.1                fansi_1.0.4             Rdpack_2.4             
##  [31] purrr_1.0.1             magrittr_2.0.3          rbibutils_2.2.13       
##  [34] MASS_7.3-57             utf8_1.2.3              lpSolveAPI_5.5.2.0-17.9
##  [37] cachem_1.0.8           
##
## also cannot even get it to install (because I cannot get devtools to install)
## on some systems (e.g. USI HP laptop), even though it worked on USI ICS
## HPC cluster (no longer available)

## "Error in array(STATS, dims[perm]) : 'dims' cannot be of length 0":
system.time ( model4 <- ergm.tapered(gn ~ edges + gwidegree(0.2, fixed=TRUE) + gwodegree(0.2, fixed=TRUE) + gwesp(0.2, fixed=TRUE) + gwdsp(0.2,fixed=TRUE) + edgecov(celegans277_distmatrix)  + nodecov('birthtime') + diff('birthtime', pow=1, dir='t-h', sign.action='identity'), taper.terms = "dependent", fixed = FALSE) )

print(model4)
summary(model4)

postscript('celegans277_tapered_model4_mcmcdiagnostics.eps')
mcmc.diagnostics(model4)
dev.off()

sink('celegans277_tapered_model4.txt')
print( summary(model4) )
sink()

save(gn, mode1, file = "model4.RData")

system.time( model4_gof <- gof(model4  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model)  )
print(model4_gof)
postscript('celegans277_tapered_model4_gof.eps')
par(mfrow=c(4,2))
plot( model4_gof, plotlogodds=TRUE)
dev.off()

warnings()


