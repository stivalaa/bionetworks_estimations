#!/usr/bin/Rscript
#
# File:    lologEstimateYeastPPI1Model1.R
# Author:  Alex Stivala
# Created: June 2021
#
# LOLOG (latent order logistic) model estimation of
# the network data for the yeast PPI (undirected) network from
# igraph Nexus graph repository (no longer available, but see
# scripts here and in ../../scripts diretory, i.e.
# getYeastEdgeListWithNodeAttr.out and getYeastEdgeListWithNodeAttr.R
# and convert_yeast_cat_attr_to_simple_attribute_file.sh).
# Ref for network from Nexus is:
#
#   Christian von Mering, Roland Krause, Berend Snel, Michael Cornell, 
#   Stephen G. Oliver, Stanley Fields & Peer Bork, Comparative assessment 
#   of large-scale data sets of protein.protein interactions, 
#   Nature 417, 399-403 (2002)
#
# Uses the lolog R package:
#    https://cran.r-project.org/web/packages/lolog/index.html
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
# Rscript lologEstimateYeastPPI1Model1.R 
#
# Output files (WARNING overwritten)
#   yeast_ppi_lolog_model1.txt
#   yeast_ppi_lolog_model1.pdf
#   gof_yeast_ppi1_lolog_model1_X.pdf
#       where X is a statistic e.g. degree,  esp, etc
#

library(igraph)
library(statnet)
library(intergraph)
library(lolog)

g <- read.graph('yeast_edgelist.txt', format='Pajek')
nodeclass <- read.table('yeast_class_attribute.txt', header=TRUE)
stopifnot(all(V(g)$id == nodeclass$id))
V(g)$class <- nodeclass$class
summary(g)
stopifnot(vcount(g) == 2617)
stopifnot(ecount(g) == 11855 )

# Convert NA class attribute to 99999
V(g)$class <- ifelse(is.na(V(g)$class), 9999, V(g)$class)

yeast_ppi <- asNetwork(g)
#print(factor(get.vertex.attribute(yeast_ppi, 'class')))
# for some reason lolog gives error with integer or factor; categroical
# node attribute apparently has to be character (could hae used original
# from Nexs,but that is gone so record integer back to arbtirary char)
set.vertex.attribute(yeast_ppi, 'class', as.character(get.vertex.attribute(yeast_ppi, 'class')))
summary(yeast_ppi, print.adj=FALSE)

maxdeg <- max(degree(yeast_ppi))

#system.time( yeast_ppi_lolog_model1 <- lolog(yeast_ppi ~ edges + twoPath + triangles + gwdegree(.2)) )
system.time( yeast_ppi_lolog_model1 <- lolog(yeast_ppi ~ edges + twoPath + triangles + gwdegree(.2) +  nodeMatch('class')) )

summary(yeast_ppi_lolog_model1)
sink('yeast_ppi_lolog_model1.txt')
summary(yeast_ppi_lolog_model1)
sink()

pdf('yeast_ppi_lolog_model1.pdf')
plot(yeast_ppi_lolog_model1)
dev.off()

system.time( gof_yeast_ppi_lolog_model1_degree <- gofit(yeast_ppi_lolog_model1, yeast_ppi ~ degree(0:maxdeg)) )
system.time( gof_yeast_ppi_lolog_model1_esp <- gofit(yeast_ppi_lolog_model1, yeast_ppi ~ esp(0:25)) )
system.time( gof_yeast_ppi_lolog_model1_edges <- gofit(yeast_ppi_lolog_model1, yeast_ppi ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_yeast_ppi_lolog_model1_degree.pdf')
plot(gof_yeast_ppi_lolog_model1_degree)
dev.off()
pdf('gof_yeast_ppi_lolog_model1_esp.pdf')
plot(gof_yeast_ppi_lolog_model1_esp)
dev.off()
pdf('gof_yeast_ppi_lolog_model1_edges.pdf')
plot(gof_yeast_ppi_lolog_model1_edges, type='box')
dev.off()

