#!/usr/bin/env Rscript
###
### File:    lolog_GMaleChem_model1.R
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
### Usage: Rscript lolog_GMaleChem_model1.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   GMaleChem1_lolog_model1.txt
###   GMaleChem1_lolog_model1.pdf
###   gof_GMaleChem11_lolog_model1_X.pdf
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

# (3 hours) ggod convergence, poor gof on mutual, idegree (lhs)
system.time( GMaleChem1_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.1, direction='in') + gwdegree(.1, direction='out')) )


# (24 hours) degen.: bimodal in-gwdegree.1 out-gwdegree.0.2, long tail on edge,tri,2path
#system.time( GMaleChem1_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(1, direction='in') + gwdegree(1, direction='out')) )

# (24 hours) degen.: bimodal out-gwdegree.0.2, long tail on edge,tri,2path
#system.time( GMaleChem1_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(0, direction='in') + gwdegree(.2, direction='out')) )

# poor gof on mutual, idegree (left) 
#system.time( GMaleChem1_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out')) )

# poor gof on mutual, esp (left end fo dist.), idegree (left), odegree (left):
#system.time( GMaleChem1_lolog_model1 <- lolog(gn ~ edges + twoPath + triangles + gwdegree(.5, direction='in') + gwdegree(.5, direction='out')) )

summary(GMaleChem1_lolog_model1)
sink('GMaleChem1_lolog_model1.txt')
summary(GMaleChem1_lolog_model1)
sink()

pdf('GMaleChem1_lolog_model1.pdf')
plot(GMaleChem1_lolog_model1)
dev.off()

system.time( gof_GMaleChem1_lolog_model1_indegree <- gofit(GMaleChem1_lolog_model1, gn ~ degree(0:maxindeg, direction='in')))
system.time( gof_GMaleChem1_lolog_model1_outdegree <- gofit(GMaleChem1_lolog_model1, gn ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_GMaleChem1_lolog_model1_esp <- gofit(GMaleChem1_lolog_model1, gn ~ esp(0:25)) )
system.time( gof_GMaleChem1_lolog_model1_edges <- gofit(GMaleChem1_lolog_model1, gn ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_GMaleChem1_lolog_model1_indegree.pdf')
plot(gof_GMaleChem1_lolog_model1_indegree)
dev.off()
pdf('gof_GMaleChem1_lolog_model1_outdegree.pdf')
plot(gof_GMaleChem1_lolog_model1_outdegree)
dev.off()
pdf('gof_GMaleChem1_lolog_model1_esp.pdf')
plot(gof_GMaleChem1_lolog_model1_esp)
dev.off()
pdf('gof_GMaleChem1_lolog_model1_edges.pdf')
plot(gof_GMaleChem1_lolog_model1_edges, type='box')
dev.off()

