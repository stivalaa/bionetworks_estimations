#!/usr/bin/Rscript
#
# File:    taperedEstimateEcoli1Model2.R
# Author:  Alex Stivala
# Created: May 2023
#
#Tapered ERGM model estimation of
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
# Uses the ergm.tapered R package:
#    https://github.com/statnet/ergm.tapered
#
# Citations for tapered ERGM:
#
# Blackburn, B., & Handcock, M. S. (2023). Practical Network Modeling via 
# Tapered Exponential-Family Random Graph Models. Journal of 
# Computational and Graphical Statistics, 32:2, 388-401
#
# Usage:
# 
# Rscript taperedEstimateEcoli1Model2.R 
#
# Output files (WARNING overwritten)
#   ecoli1_tapered_model2.txt
#   ecoli1_tapered_model2_mcmcdiagnostics.eps
#   gof_ecoli11_tapered_model2.eps
#   ecoli1_tapered_model2.RData
#

library(statnet)
library(ergm.tapered)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

data(ecoli)
gn <- ecoli1
summary(gn, print.adj=FALSE)


system.time(tapered_model2  <- ergm.tapered(ecoli1 ~ edges + gwidegree(2, fixed=TRUE) + gwodegree(0, fixed=TRUE) + ttriple + twopath + nodecov("self") + nodematch("self"), taper.terms = "dependent", fixed = FALSE))

print(tapered_model2)
summary(tapered_model2, extended = TRUE)

postscript('ecoli_tapered_model2_mcmcdiagnostics.eps')
mcmc.diagnostics(tapered_model2)
dev.off()

sink('ecoli_tapered_model2.txt')
print( summary(tapered_model2, extended = FALSE) )
sink()

save(gn, tapered_model2, file = "tapered_model2.RData")

system.time( tapered_model2_gof <-  gof(tapered_model2, GOF =  ~ idegree + odegree + distance + espartners + dspartners + triadcensus + model) )
print(tapered_model2_gof)
postscript('ecoli_tapered_model2_gof.eps')
par(mfrow=c(4,2))
plot( tapered_model2_gof, plotlogodds=TRUE)
dev.off()

warnings()

