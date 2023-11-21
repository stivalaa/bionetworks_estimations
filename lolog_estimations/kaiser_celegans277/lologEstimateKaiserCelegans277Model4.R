#!/usr/bin/env Rscript
###
### File:    lologEstimateKaiserCelegans277Model4.R
### Author:  Alex Stivala
### Created: November 2023
###
### Estimating LOLOG parameters for a model for the Kaiser C. elegans 
### 277 node neural network data.
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
### Usage: lologEstimateKaiserCelegans277Model4.R
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   celegans277_lolog_model4.txt
###   celegans277_lolog_model4.pdf
###   gof_celegans2771_lolog_model4_X.pdf
###       where X is a statistic e.g. indegree, outdegree, esp, etc.
### WARNING: overwrites output files if they exist
###

## Note other libraries especially statnet loaded later to avoid clashes


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
library(lolog)

sessionInfo()

gn <- asNetwork(g)

maxindeg <- max(degree(gn, cmode='indegree'))
maxoutdeg <- max(degree(gn, cmode='outdegree'))

summary(degree(gn, cmode='indegree'))
summary(degree(gn, cmode='outdegree'))

## bad model diagnostics and gof
# took 2.5 hours on lenovo pc
system.time( celegans277_lolog_model4 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out') + nodeCov('birthtime') | birthtime) )

## No diff() in lolog:
#system.time( celegans277_lolog_model4 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out') + diff('birthtime', pow=1, dir='t-h', sign.action='identity') | birthtime) )



summary(celegans277_lolog_model4)
sink('celegans277_lolog_model4.txt')
summary(celegans277_lolog_model4)
sink()

pdf('celegans277_lolog_model4.pdf')
plot(celegans277_lolog_model4)
dev.off()

system.time( gof_celegans277_lolog_model4_indegree <- gofit(celegans277_lolog_model4, gn ~ degree(0:maxindeg, direction='in')))
system.time( gof_celegans277_lolog_model4_outdegree <- gofit(celegans277_lolog_model4, gn ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_celegans277_lolog_model4_esp <- gofit(celegans277_lolog_model4, gn ~ esp(0:25)) )
system.time( gof_celegans277_lolog_model4_edges <- gofit(celegans277_lolog_model4, gn ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_celegans277_lolog_model4_indegree.pdf')
plot(gof_celegans277_lolog_model4_indegree)
dev.off()
pdf('gof_celegans277_lolog_model4_outdegree.pdf')
plot(gof_celegans277_lolog_model4_outdegree)
dev.off()
pdf('gof_celegans277_lolog_model4_esp.pdf')
plot(gof_celegans277_lolog_model4_esp)
dev.off()
pdf('gof_celegans277_lolog_model4_edges.pdf')
plot(gof_celegans277_lolog_model4_edges, type='box')
dev.off()

