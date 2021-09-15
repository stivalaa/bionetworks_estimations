#!/usr/bin/Rscript
##
## File:    motifsNetMODEobsSim.R
## Author:  Alex Stivala
## Created: September 2021
##
## Use NetMODE (1.04) to read observed and set of simulated graphs,
## build table of counts of motifs in them.
## Note using NetMODE only to count the motifs, not to simulated any networks
## here, the idea is to use networks simulated by some external method
## (in particular, ERGM, output from SimulateERGM in EstimNetDirected for
## example)
##
## Usage: Rscript statsEsimtNetDirectedSimFit.R  netfilename simNetFilePrefix
##  netfilename is the Pajek format observed graph (the input arclistFile
##     for EstimNetDirected)
##  simNetFilePreifx is the prefix of the simulated network filenames
##    this files have _x.net appended by SimulteERGM
##
## Example:
## Rscript motifsNetMODEobsSim.R ecoli1_arclist.txt simulation_estimated_ecoli1_structural
##
## Output to stdout is whitepsace-delimited table (useful for reading back
## into R with read.table() for example) with motif identifier, 
## network identifier ("observed" or simulation number) and corresponding
## motif counts from NetMODE.
##
## Citation for NetMODE is:
##   Li, X., Stones, R. J., Wang, H., Deng, H., Liu, X., & Wang, G. (2012).
##   NetMODE: Network motif detection without nauty. PloS One, 7(12), e50093.
##
## and is available from:
##  https://sourceforge.net/projects/netmode/files/NetMODE%201.04/
##
## Uses the NetMODE R interface which in turn
## uses the igraph library:
##
##   Csardi G, Nepusz T: The igraph software package for complex network
##   research, InterJournal, Complex Systems
##   1695. 2006. http://igraph.org
##
##
##
##


## read in R source file from directory where this script is located
##http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
source_local <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
  source(paste(base_dir, fname, sep=.Platform$file.sep))
}

source_local('snowballSample.R')

## See NetMODE.R for desciprtion of R interface
source("/home/stivala/NetMODE104/NetMODE.R")


###
### Main
###

args <- commandArgs(trailingOnly=TRUE)
basearg <- 0
if (length(args) != 2) {
  cat("Usage: Rscript motifsNetMODEobsSim.R netfilename simNetFilePrefix\n")
  quit(save="no")
}
netfilename <- args[basearg+1]
simnetfileprefix <- args[basearg+2]


graph_glob <- paste(simnetfileprefix, "_[0-9]*[.]net", sep='')

g_obs <- read_graph_file(netfilename, directed = TRUE)

sim_files <- Sys.glob(graph_glob)
sim_graphs <- sapply(sim_files,
                     FUN = function(f) read_graph_file(f,
                                                       directed=TRUE),
                     simplify = FALSE)

num_nodes <- vcount(g_obs)
## all simulated graphs must have the same number of nodes
stopifnot(length(unique((sapply(sim_graphs, function(g) vcount(g))))) == 1)
## and it must be the same a the number of nodes in the observed graph
stopifnot(num_nodes == vcount(sim_graphs[[1]]))
num_sim <- length(sim_graphs)

## 4-node motifs

motif_size <- 4
motif_ids <- c(204,  # bi-fan
               2182  # bi-parallel
              )

cat("motif_size motif_id network_id network_type motif_count\n")

for (motif_id in motif_ids) {
  obs_nm <- NetMODE(g_obs, k = motif_size, N = 0) # count motifs only, no simulation
  obs_motif_idx <- which(obs_nm[[1]] == motif_id)
  if (length(obs_motif_idx) == 0) {
    obs_motif_count <- 0
  } else {
    obs_motif_count <- obs_nm[[2]][obs_motif_idx]
  }
  cat (motif_size, motif_id, "observed", "observed", obs_motif_count, "\n")
  
  for (i in 1:length(sim_graphs)) {
    sim_nm <- NetMODE(sim_graphs[[i]], k = motif_size, N = 0) # count motifs only, no simulation
    sim_motif_idx <- which(sim_nm[[1]] == motif_id)
    if (length(sim_motif_idx) == 0) {
      sim_motif_count <- 0
    } else {
      sim_motif_count <- sim_nm[[2]][sim_motif_idx]
    }
    cat (motif_size, motif_id, i, "simulated", sim_motif_count, "\n")
  }
}
