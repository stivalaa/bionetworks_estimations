#!/usr/bin/Rscript
#
# File:    lologEstimateAlonYeastTranscriptionModel1.R
# Author:  Alex Stivala
# Created: June 2021
#
# LOLOG (latent order logistic) model estimation of yeast transcription network
# read from  the yeatInter_st.txt file downloaded from 
# http://www.weizmann.ac.il/mcb/UriAlon/download/collection-complex-networks
# and write Pajek arc list format.
#
# Citation for data is
#
#   Milo, R., Shen-Orr, S., Itzkovitz, S., Kashtan, N., 
#   Chklovskii, D., & Alon, U. (2002). Network motifs: simple building blocks 
#   of complex networks. Science, 298(5594), 824-827.
#
#
# Usage:
#   Rscript lologEstimateAlonYeastTranscriptionModel1.R 
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
# Rscript lologEstimateYeastTranscriptionModel1.R 
#
# Output files (WARNING overwritten)
#   yeast_transcription_lolog_model1.txt
#   yeast_transcription_lolog_model1.pdf
#   gof_yeast_transcription1_lolog_model1.pdf
#

library(igraph)
library(statnet)
library(intergraph)
library(lolog)


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

maxindeg <- max(igraph::degree(g, mode='in'))
maxoutdeg <- max(igraph::degree(g, mode='out'))

yeast_transcription <- asNetwork(g)
summary(yeast_transcription, print.adj=FALSE)

system.time( yeast_transcription_lolog_model1 <- lolog(yeast_transcription ~ edges + twoPath + triangles + gwdegree(.2, direction='in') + gwdegree(.2, direction='out')) )

summary(yeast_transcription_lolog_model1)
sink('yeast_transcription_lolog_model1.txt')
summary(yeast_transcription_lolog_model1)
sink()

pdf('yeast_transcription_lolog_model1.pdf')
plot(yeast_transcription_lolog_model1)
dev.off()

system.time( gof_yeast_transcription_lolog_model1_indegree <- gofit(yeast_transcription_lolog_model1, yeast_transcription ~ degree(0:maxindeg, direction='in')))
system.time( gof_yeast_transcription_lolog_model1_outdegree <- gofit(yeast_transcription_lolog_model1, yeast_transcription ~ degree(0:maxoutdeg, direction='out')))
system.time( gof_yeast_transcription_lolog_model1_esp <- gofit(yeast_transcription_lolog_model1, yeast_transcription ~ esp(0:25)) )
system.time( gof_yeast_transcription_lolog_model1_edges <- gofit(yeast_transcription_lolog_model1, yeast_transcription ~ edges + mutual) )

# Does not work: par(mfrow=c(2,2))
# so have to have separate file for each plot
pdf('gof_yeast_transcription_lolog_model1_indegree.pdf')
plot(gof_yeast_transcription_lolog_model1_indegree)
dev.off()
pdf('gof_yeast_transcription_lolog_model1_outdegree.pdf')
plot(gof_yeast_transcription_lolog_model1_outdegree)
dev.off()
pdf('gof_yeast_transcription_lolog_model1_esp.pdf')
plot(gof_yeast_transcription_lolog_model1_esp)
dev.off()
pdf('gof_yeast_transcription_lolog_model1_edges.pdf')
plot(gof_yeast_transcription_lolog_model1_edges, type='box')
dev.off()

