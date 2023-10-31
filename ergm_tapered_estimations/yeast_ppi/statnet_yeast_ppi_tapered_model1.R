#!/usr/bin/env Rscript
###
### File:    statnet_yeast_ppi_tapered_model1.R
### Author:  Alex Stivala
### Created: May 2023
###
### Estimating ERGM parameters for a model for 
###  undirected yeast ppi network.
###
### Citation for data is:
###
### von Mering C, Krause R, Snel B, Cornell M, Oliver SG, Fields S, Bork P
### (2002) Comparative assessment of large-scale data sets of protein-protein
### interactions. Nature 417(6887):399403
###
### Citations for tapered ERGM:
###
### Blackburn, B., & Handcock, M. S. (2023). Practical Network Modeling via 
### Tapered Exponential-Family Random Graph Models. Journal of 
### Computational and Graphical Statistics, 32:2, 388-401
###
### Usage: Rscript statnet_yeast_ppi_tapered_model1.R
###
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'yeast_ppi_statnet_tapered_model1.txt'
###   'yeast_ppi_statnet_tapered_model1_mcmcdiagnostics.eps'
###   'yeast_ppi_statnet_tapered_model1_gof.eps'
###    tapered_model1.RData
### WARNING: overwrites output files if they exist
###
###

library(igraph)
library(intergraph)
library(statnet)
library(ergm.tapered)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

g <- read.graph('yeast_edgelist.txt', format='pajek')
summary(g)
g <- simplify(as.undirected(g))
summary(g)
gn <- asNetwork(g)
summary(gn, print.adj=FALSE)

# (17 hours) good convergece, bad gof on degree, esp, gesodesic (especially)
system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree(0.1, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Bad convergence MCMC diagnostics plot (4 hours):
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree(1.0, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# No estimate for gwdeg.fixed.0 (Model statistics 'gwdeg.fixed.0' are not varying. This may indicate that the obs erved data occupies an extreme point in the sample space or that the estimation has reached a dead-end configuration.)
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree(0, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Good convergence (MCMC diagnostics), 2 hours, but bad GoF, esp. geodesic
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree(0.2, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Good convergence (MCMC diagnostics), 29 hours, but bad GoF, esp. geodesic
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree(0.5, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Does not converge:
#system.time(tapered_model1  <- ergm.tapered(gn ~ edges + gwdegree + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

print(tapered_model1)
summary(tapered_model1)

postscript('yeast_ppi_statnet_tapered_model1_mcmcdiagnostics.eps')
mcmc.diagnostics(tapered_model1)
dev.off()

sink('yeast_ppi_statnet_tapered_model1.txt')
print( summary(tapered_model1) )
sink()

save(gn, tapered_model1, file = "tapered_model1.RData")

system.time( tapered_model1_gof <-  gof(tapered_model1, GOF =  ~ degree + distance + espartners + dspartners + triadcensus + model ) )

print(tapered_model1_gof)
postscript('yeast_ppi_statnet_tapered_model1_gof.eps')
par(mfrow=c(3,2))
plot( tapered_model1_gof, plotlogodds=TRUE)
dev.off()

warnings()

