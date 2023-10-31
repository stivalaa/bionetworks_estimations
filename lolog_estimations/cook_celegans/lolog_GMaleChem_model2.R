#!/usr/bin/env Rscript
###
### File:    lolog_GMaleChem_model2.R
### Author:  Alex Stivala
### Created: May 2023
###
### Estimating LOLOG parameters for a model for 
### C. elegans whole connectome (male, chemical [directed]) from 
###
### Citation for data is:
###
###  Cook, S. J., Jarrell, T. A., Brittin, C. A., Wang, Y., Bloniarz, 
###  A. E., Yakovlev, M. A., ... & Emmons, S. W. (2019).
###  Whole-animal connectomes of both Caenorhabditis elegans sexes.
###  Nature, 571(7763), 63-71.
###
### Usage: Rscript lolog_GMaleChem_model2.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   GMaleChem1_lolog_model2.txt
###   GMaleChem1_lolog_model2.pdf
###   gof_GMaleChem11_lolog_model2_X.pdf
###       where X is a statistic e.g. indegree, outdegree, esp, etc.
### WARNING: overwrites output files if they exist
###
###

library(igraph)
library(intergraph)
library(statnet)
library(lolog)


options(scipen=9999) # force decimals not scientific notation

g <- read.graph('GMaleChem_arclist.txt', format='pajek')
summary(g)
gn  <- asNetwork(g)

maxindeg <- max(degree(gn, cmode='indegree'))
maxoutdeg <- max(degree(gn, cmode='outdegree'))

summary(degree(gn, cmode='indegree'))
summary(degree(gn, cmode='outdegree'))

# (8 hours) bad convergence (long tail on mutual, triangles, twopath); bad gof on esp, idegree 
system.time( GMaleChem1_lolog_model2 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.1, direction='in') + gwdegree(.1, direction='out') + mutual) )

summary(GMaleChem1_lolog_model2)
sink('GMaleChem1_lolog_model2.txt')
summary(GMaleChem1_lolog_model2)
sink()

pdf('GMaleChem1_lolog_model2.pdf')
plot(GMaleChem1_lolog_model2)
dev.off()

system.time( gof_GMaleChem1_lolog_model2_indegree <- gofit(GMaleChem1_lolog_model2, gn ~ degree(0:maxindeg, direction='in')))
system.time( gof_GMaleChem1_lolog_model2_outdegree <- gofit(GMaleChem1_lolog_model2, gn ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_GMaleChem1_lolog_model2_esp <- gofit(GMaleChem1_lolog_model2, gn ~ esp(0:25)) )
system.time( gof_GMaleChem1_lolog_model2_edges <- gofit(GMaleChem1_lolog_model2, gn ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_GMaleChem1_lolog_model2_indegree.pdf')
plot(gof_GMaleChem1_lolog_model2_indegree)
dev.off()
pdf('gof_GMaleChem1_lolog_model2_outdegree.pdf')
plot(gof_GMaleChem1_lolog_model2_outdegree)
dev.off()
pdf('gof_GMaleChem1_lolog_model2_esp.pdf')
plot(gof_GMaleChem1_lolog_model2_esp)
dev.off()
pdf('gof_GMaleChem1_lolog_model2_edges.pdf')
plot(gof_GMaleChem1_lolog_model2_edges, type='box')
dev.off()

