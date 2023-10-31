#!/usr/bin/Rscript
#
# File:    lologEstimateEcoli1Model1.R
# Author:  Alex Stivala
# Created: June 2021
#
#LOLOG (latent order logistic) model estimation of
#the network data for the E. coli regulatory network (directed)
#as used (but undirected version)
#in Saul & Filkov 2007 and Hummel et al. 2012. The network is
#obtained from the ergm package data(ecoli) and other citations required
#are
#   Salgado et al (2001), Regulondb (version 3.2): Transcriptional
#     Regulation and Operon Organization in Escherichia Coli K-12,
#     _Nucleic Acids Research_, 29(1): 72-74.
#
#     Shen-Orr et al (2002), Network Motifs in the Transcriptional
#     Regulation Network of Escerichia Coli, _Nature Genetics_, 31(1):
#     64-68.
#
#
# self-loops are removed (although there are none anyway)
# Instead the binary attribute self used to mark self-regulating operons
# is used.
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
# Rscript lologEstimateEcoli1Model1.R 
#
# Output files (WARNING overwritten)
#   ecoli1_lolog_model1.txt
#   ecoli1_lolog_model1.pdf
#   gof_ecoli11_lolog_model1_X.pdf
#       where X is a statistic e.g. indegree, outdegree, esp, etc.
#

library(statnet)
library(lolog)


data(ecoli)
gn <- ecoli1
summary(gn, print.adj=FALSE)
gn <- as.network.matrix(as.matrix.network(gn), directed=TRUE,
                        hyper = FALSE, loops = FALSE, multiple = FALSE)
summary(gn, print.adj=FALSE)

maxindeg <- max(degree(gn, cmode='indegree'))
maxoutdeg <- max(degree(gn, cmode='outdegree'))

system.time( ecoli1_lolog_model1 <- lolog(ecoli1 ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out') + nodeCov('self') + nodeMatch('self')) )

summary(ecoli1_lolog_model1)
sink('ecoli1_lolog_model1.txt')
summary(ecoli1_lolog_model1)
sink()

pdf('ecoli1_lolog_model1.pdf')
plot(ecoli1_lolog_model1)
dev.off()

system.time( gof_ecoli1_lolog_model1_indegree <- gofit(ecoli1_lolog_model1, ecoli1 ~ degree(0:maxindeg, direction='in')))
system.time( gof_ecoli1_lolog_model1_outdegree <- gofit(ecoli1_lolog_model1, ecoli1 ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_ecoli1_lolog_model1_esp <- gofit(ecoli1_lolog_model1, ecoli1 ~ esp(0:25)) )
system.time( gof_ecoli1_lolog_model1_edges <- gofit(ecoli1_lolog_model1, ecoli1 ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_ecoli1_lolog_model1_indegree.pdf')
plot(gof_ecoli1_lolog_model1_indegree)
dev.off()
pdf('gof_ecoli1_lolog_model1_outdegree.pdf')
plot(gof_ecoli1_lolog_model1_outdegree)
dev.off()
pdf('gof_ecoli1_lolog_model1_esp.pdf')
plot(gof_ecoli1_lolog_model1_esp)
dev.off()
pdf('gof_ecoli1_lolog_model1_edges.pdf')
plot(gof_ecoli1_lolog_model1_edges, type='box')
dev.off()

