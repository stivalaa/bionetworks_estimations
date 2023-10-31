#!/usr/bin/Rscript
#
# File:    lologEstimateHIPPIE1Model1.R
# Author:  Alex Stivala
# Created: June 2023
#
# LOLOG (latent order logistic) model estimation of
# the network data for the human PPI data from HIPPIE.
#
# Citations for lolog:
#
#   Ian E. Fellows (2019). lolog: Latent Order Logistic Graph Models. R
#   package version 1.2. https://CRAN.R-project.org/package=lolog
#
#   Fellows, I. E. (2018). A New Generative Statistical Model for Graphs:
#   The Latent Order Logistic (LOLOG) Model. arXiv preprint arXiv:1804.04583.
#
# Usage:
# 
# Rscript lologEstimateHIPPIE1Model1.R 
#
# Output files (WARNING overwritten)
#   hippie_lolog_model1.txt
#   hippie_lolog_model1.pdf
#   gof_hippie1_lolog_model1_X.pdf
#       where X is a statistic e.g. degree,  esp, etc
#

# Note very large memory usge, seems to steadily increase after each iteration

library(igraph)
library(statnet)
library(intergraph)
library(lolog)

g <- read.graph('hippie_ppi_high_edgelist.txt', format='Pajek')
catattr <- read.table('hippie_ppi_high_cellular_component_attribute.txt', header=TRUE)
stopifnot(all(V(g)$id == catattr$id))
V(g)$cellularComponent <- catattr$cellularComponent
summary(g)
stopifnot(vcount(g) == 11517)
stopifnot(ecount(g) == 47184 )

# NA cellularComponent attribute is already 99999

hippie <- asNetwork(g)
# for some reason lolog gives error with integer or factor; categroical
# node attribute apparently has to be character
set.vertex.attribute(hippie, 'cellularComponent', as.character(get.vertex.attribute(hippie, 'cellularComponent')))
summary(hippie, print.adj=FALSE)

maxdeg <- max(degree(hippie))

# does not converge within 48 hour max time limit
system.time( hippie_lolog_model1 <- lolog(hippie ~ edges + twoPath + triangles + gwdegree(.2)) )

summary(hippie_lolog_model1)
sink('hippie_lolog_model1.txt')
summary(hippie_lolog_model1)
sink()

pdf('hippie_lolog_model1.pdf')
plot(hippie_lolog_model1)
dev.off()

system.time( gof_hippie_lolog_model1_degree <- gofit(hippie_lolog_model1, hippie ~ degree(0:maxdeg)) )
system.time( gof_hippie_lolog_model1_esp <- gofit(hippie_lolog_model1, hippie ~ esp(0:25)) )
system.time( gof_hippie_lolog_model1_edges <- gofit(hippie_lolog_model1, hippie ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_hippie_lolog_model1_degree.pdf')
plot(gof_hippie_lolog_model1_degree)
dev.off()
pdf('gof_hippie_lolog_model1_esp.pdf')
plot(gof_hippie_lolog_model1_esp)
dev.off()
pdf('gof_hippie_lolog_model1_edges.pdf')
plot(gof_hippie_lolog_model1_edges, type='box')
dev.off()

