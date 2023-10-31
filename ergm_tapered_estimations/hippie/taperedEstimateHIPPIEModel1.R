#!/usr/bin/Rscript
###
### File:    taperedEstimateHIPPIE1Model1.R
### Author:  Alex Stivala
### Created: May 2023
###
### tapered ERGM estimation of
### the network data for the human PPI data from HIPPIE.
###
### Citations for tapered ERGM:
###
### Blackburn, B., & Handcock, M. S. (2023). Practical Network Modeling via 
### Tapered Exponential-Family Random Graph Models. Journal of 
### Computational and Graphical Statistics, 32:2, 388-401
###
### Usage:
### 
### Rscript taperedEstimateHIPPIE1Model1.R 
###
### Output files (WARNING overwritten)
###
### Model and GoF output is to stdout, also writes output files to cwd:
###   'hippie_statnet_tapered_model1.txt'
###   'hippie_statnet_tapered_model1_mcmcdiagnostics.eps'
###   'hippie_statnet_tapered_model1_gof.eps'
###    tapered_model1.RData
### WARNING: overwrites output files if they exist
###
###


library(igraph)
library(statnet)
library(intergraph)
library(ergm.tapered)

sessionInfo()

options(scipen=9999) # force decimals not scientific notation
options(width=9999)  # do not line wrap, so can parse output

g <- read.graph('hippie_ppi_high_edgelist.txt', format='Pajek')
catattr <- read.table('hippie_ppi_high_cellular_component_attribute.txt', header=TRUE)
stopifnot(all(V(g)$id == catattr$id))
V(g)$cellularComponent <- catattr$cellularComponent
summary(g)
stopifnot(vcount(g) == 11517)
stopifnot(ecount(g) == 47184 )


hippie <- asNetwork(g)
summary(hippie, print.adj=FALSE)

system.time(tapered_model1  <- ergm.tapered(hippie ~ edges + gwdegree(0.0, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE, control = control.ergm.tapered(MCMLE.maxit = 600)) )

# Does not converge afer 120 iterations (10 hours)
#system.time(tapered_model1  <- ergm.tapered(hippie ~ edges + gwdegree(0.0, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE, control = control.ergm.tapered(MCMLE.maxit = 120)) )

# Does not converge after 60 iterations (17 hours, total time 20 hours)
#system.time(tapered_model1  <- ergm.tapered(hippie ~ edges + gwdegree(0.0, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Does not converge  (18 hours, total time for this script 21 hours):
#system.time(tapered_model1  <- ergm.tapered(hippie ~ edges + gwdegree(0.5, fixed = TRUE) + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

# Does not converge:
#system.time(tapered_model1  <- ergm.tapered(hippie ~ edges + gwdegree + triangle + twopath, taper.terms = "dependent", fixed = FALSE))

print(tapered_model1)
summary(tapered_model1)

postscript('hippie_statnet_tapered_model1_mcmcdiagnostics.eps')
mcmc.diagnostics(tapered_model1)
dev.off()

sink('hippie_statnet_tapered_model1.txt')
print( summary(tapered_model1) )
sink()

save(hippie, tapered_model1, file = "tapered_model1.RData")

system.time( tapered_model1_gof <-  gof(tapered_model1, GOF =  ~ degree + distance + espartners + dspartners + triadcensus + model ) )

print(tapered_model1_gof)
postscript('hippie_statnet_tapered_model1_gof.eps')
par(mfrow=c(3,2))
plot( tapered_model1_gof, plotlogodds=TRUE)
dev.off()

warnings()

