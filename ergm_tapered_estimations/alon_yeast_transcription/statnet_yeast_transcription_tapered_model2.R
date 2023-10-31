#!/usr/bin/env Rscript
###
### File:    statnet_yeast_transcription_tapered_model2.R
### Author:  Alex Stivala
### Created: May 2023
###
### Estimating ERGM parameters for a model for 
###  directed yeast transcription network
###  from http://www.weizmann.ac.il/mcb/UriAlon/download/collection-complex-networks
###
### Note that the citation Milo et al. (2002) Science 298:824-827 cites
### 
### Costanzo, M. C., Crawford, M. E., Hirschman, J. E., Kranz, J. E.,
### Olsen, P., Robertson, L. S., ... & Lengieza, C. (2001). YPD,
### PombePD and WormPD: model organism volumes of the
### BioKnowledge Library, an integrated resource for protein
### information. Nucleic Acids Research, 29(1), 75-79.
### 
### as source for yeast TF network.
###
### Citations for tapered ERGM:
###
### Blackburn, B., & Handcock, M. S. (2023). Practical Network Modeling via 
### Tapered Exponential-Family Random Graph Models. Journal of 
### Computational and Graphical Statistics, 32:2, 388-401
### 
###
### Usage: Rscript statnet_yeast_transcription_tapered_model2.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'yeast_transcription_statnet_tapered_model2.txt'
###   'yeast_transcription_statnet_tapered_model2_mcmcdiagnostics.eps'
###   'yeast_transcription_statnet_tapered_model2_gof.eps'
###    tapered_model2.RData
### WARNING: overwrites output files if they exist
###
###

library(igraph)
library(statnet)
library(ergm.tapered)
library(intergraph)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

yeastinter <- read.table("yeastinter_st.txt", header = FALSE)

# from yeastreadme.doc:
#
#   yeastInter_st.txt is a text file that includes all the interactions
#   in the network. The convention used in the file is that the order of
#   the columns is: regulating gene (TF), regulated gene, mode of
#   regulation.  In the basic yeastInter.txt network the mode of
#   regulation is always 1, we did not differentiate between activators
#   and repressors. See below for information on datasets that include the
#   mode of regulation.

yeastinter$V3 <- NULL # drop 3rd column (always 1 for regulation mode)
g <- graph.edgelist(as.matrix(yeastinter))

summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)
gn <- asNetwork(g)

# poor convergence on ttriple and twopath (model 1, with mutual, is better)
system.time( tapered_model2 <- ergm.tapered(gn ~ edges + gwidegree(0.5, fixed=T) + gwodegree(1.5, fixed=T) + ttriple + twopath, taper.terms = "dependent", fixed = FALSE) )


print(tapered_model2)
summary(tapered_model2)

postscript('yeast_transcription_statnet_tapered_model2_mcmcdiagnostics.eps')
mcmc.diagnostics(tapered_model2)
dev.off()

sink('yeast_transcription_statnet_tapered_model2.txt')
print( summary(tapered_model2) )
sink()

save(gn, tapered_model2, file = "tapered_model2.RData")

system.time( tapered_model2_gof <-  gof(tapered_model2, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model ) )
print(tapered_model2_gof)
postscript('yeast_transcription_statnet_tapered_model2_gof.eps')
par(mfrow=c(4,2))
plot( tapered_model2_gof, plotlogodds=TRUE)
dev.off()

warnings()

