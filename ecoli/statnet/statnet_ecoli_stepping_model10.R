#!/usr/bin/env Rscript
###
### File:    statnet_ecoli_stepping_model10.R
### Author:  Alex Stivala
### Created: September 2021
###
### Estimating ERGM parameters for a model for 
###  directed E. coli regulatory network
###
### Citation for data is:
###
###   Salgado et al (2001), Regulondb (version 3.2): Transcriptional
###     Regulation and Operon Organization in Escherichia Coli K-12,
###     _Nucleic Acids Research_, 29(1): 72-74.
###
###     Shen-Orr et al (2002), Network Motifs in the Transcriptional
###     Regulation Network of Escerichia Coli, _Nature Genetics_, 31(1):
###     64-68.
###
### From '?ecoli' in statnet:
###    The network object 'ecoli1' is directed, with 423 nodes and 519
###     arcs. The object 'ecoli2' is an undirected version of the same
###     network, in which all arcs are treated as edges and the five
###     isolated nodes (which exhibit only self-regulation in 'ecoli1')
###     are removed, leaving 418 nodes.
###
### Usage: Rscript statnet_ecoli_stepping_model10.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'ecoli_statnet_stepping_model10.txt'
###   'ecoli_statnet_stepping_model10_mcmcdiagnostics.eps'
###   'ecoli_statnet_stepping_model10_gof.eps'
###    stepping_model10.RData
### WARNING: overwrites output files if they exist
###
###

library(statnet)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

data(ecoli)
gn <- ecoli1
summary(gn, print.adj=FALSE)

system.time( stepping_model10 <- ergm(gn ~ edges + gwidegree(2.0, fixed=TRUE) + gwodegree(0.0, fixed=TRUE) + dgwesp(log(2.0), fixed = TRUE, type = "OTP") + dgwdsp(log(2.0), fixed = TRUE, type = "OTP") + nodematch("self"), control = control.ergm(main.method = "Stepping")) )

print(stepping_model10)
summary(stepping_model10)

postscript('ecoli_statnet_stepping_model10_mcmcdiagnostics.eps')
mcmc.diagnostics(stepping_model10)
dev.off()

sink('ecoli_statnet_stepping_model10.txt')
print( summary(stepping_model10) ) ## sometimes need print(summary()), sometimes just summary() works (but not always). Why???
sink()

save(gn, stepping_model10, file = "stepping_model10.RData")

system.time( stepping_model10_gof <-  gof(stepping_model10, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model) )
print(stepping_model10_gof)
postscript('ecoli_statnet_stepping_model10_gof.eps')
par(mfrow=c(4,2))
plot( stepping_model10_gof, plotlogodds=TRUE)
dev.off()

warnings()

