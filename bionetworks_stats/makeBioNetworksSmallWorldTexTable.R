#!/usr/bin/Rscript
#
# File:    makeBioNetworksSmallWorldTexTable.R
# Author:  Alex Stivala
# Created: November 2016
#
# Read in all biological network data and make Latex table with graph
# small world statistics
#
# Network file locations are hardcoded here.
#
# Usage:
# 
# Rscript makeBioNetworksSmallWorldTexTable.R [-c]
#
#
# if -c is specified, use only the giant component of the network

library(igraph)
library(boot)


graphs <- c(
    "../undirected/arabidopsis_interactome/arabadopsis_interactome_edgelist.txt",
    "../undirected/yeast/model1/yeast_edgelist.txt",
    "../undirected/human_interactome/human_interactome_edgelist.txt",
    "../undirected/hippie/model1/hippie_ppi_high_edgelist.txt",
    "../undirected/worm_ppi/worm_ppi_edgelist.txt",
    "../ecoli/estimnetdirected/ecoli1_arclist.txt",
    "../gerstein_ecoli/ecoli_arclist.txt",
    "../alon_yeast_transcription/yeast_transcription_arclist.txt",
    "../gerstein_yeast/yeast_arclist.txt",
    "../fly_medulla/model1/fly_medulla_arclist.txt",
    "../mouse_retina_undirected/mouse_retina_1.graphml" # not really directed
    )

# description of graph must line up with filename pattern above
descrs <- c(
    "\\textit{A.~thaliana} PPI",
    "Yeast PPI",
    "Human PPI",
    "Human PPI (HIPPIE)",
    "\\textit{C. elegans} PPI",
    "Alon \\textit{E.~coli} regulatory",
    "Gerstein \\textit{E.~coli} regulatory",
    "Alon yeast regulatory",
    "Gerstein yeast regulatory",
    "\\textit{Drosophila} optic medulla",
    "Mouse retina neural network" # not really directed
    )

num_samples <- 1000 # number of random networks to average over
Replicates <- 20000  # bootstrap replicates
bootstrap_num_threads <- 20 # number of cores to use in multicore boot



#
# giant_component() - return largest connected component of the graph
# 
# Paramters:
#    graph - igraph to get giant componetn of
#
# Return value:
#    largest connected component of graph
#
giant.component <- function(graph) {
  cl <- clusters(graph)
  return(induced.subgraph(graph, which(cl$membership == which.max(cl$csize))))
}



#
# function to obtain mean, to be used as parameter to boot()
#
mean_bootwrapper <- function(data, indices) {
    estimates <- data[indices]
    return( mean(estimates) )
}



#
# Use boot package to compute confidence interval with adjusted bootstrap
# percentile method
#
# Parameters:
#     values - vector of esimated values
#
# Return value:
#    named list with three elements:
#       mean  - mean value
#       lower - lower value of c.i.
#       upper - upper value of c.i.
#
bootstrap <- function(values) {

  bootresults <- boot(data=values, statistic=mean_bootwrapper, R=Replicates,
                      parallel="multicore", ncpus=bootstrap_num_threads)
  bootCIresult <- boot.ci(bootresults, type="bca")  # 95% C.I. by default
  return(list(mean=bootresults$t0,
              lower=bootCIresult$bca[4],
              upper=bootCIresult$bca[5]))
}



# 
# main
#


args <- commandArgs(trailingOnly=TRUE)

use_giant_component <- FALSE
if (length(args) > 0 && args[1] == '-c') {
    use_giant_component <- TRUE
}



cat('\\begin{tabular}{lrrrrrrrr}\n')
cat('\\hline\n')
cat('Network & N  & $L_{\\mathrm{g}}$ & $L_{\\mathrm{rand}}$ & $C_{\\mathrm{g}}$ & $C_{\\mathrm{rand}}$ &  $S^{\\Delta}$ & \\multicolumn{2}{c}{95\\% C.I.}\\\\\n')
cat('        &    &                   &                      &                   &                      &             &  lower   & upper \\\\\n')
cat('\\hline\n')
for (i in 1:length(graphs)) {

    if (grepl("\\.graphml$", graphs[i])) {
        g <- read.graph(graphs[i], format="graphml")
    } else {
        g <- read.graph(graphs[i], format="pajek")
    }
    g <- as.undirected(g) 
    g <- simplify(g)

    if (use_giant_component) {
        g <- giant.component(g)
    }
    descr <- descrs[i]
    nodecount <- vcount(g)
    edgecount <- ecount(g)
    avg_path_length <- average.path.length(g, directed=FALSE)
    cc <- transitivity(g, type="global")

    # random graph with same N and number of edges
    # average over a large number of them
    randgraphs <- replicate(num_samples, erdos.renyi.game(nodecount, edgecount, type="gnm", directed=FALSE), simplify=FALSE)
    avg_path_length_rand <- sapply(randgraphs, function(g) average.path.length(g, directed=FALSE))
    cc_rand <- sapply(randgraphs, function(g) transitivity(g, type="global"))

    # small-world index S^{\Delta} as defined by Humphries & Gurney 2008
    # "Network 'Small-World-Ness': A Quantitative Method for Determining
    # Canonical Network Equivalance" PLOS ONE 3:(4):e0002051
    # Small-world if S_Delta > 1
    gamma_cc <- cc / cc_rand
    lambda <- avg_path_length / avg_path_length_rand
    S_Delta <- gamma_cc / lambda

    old_len <- length(S_Delta)
    S_Delta <- S_Delta[which(!is.nan(S_Delta) & !is.infinite(S_Delta))]
    if (length(S_Delta) != old_len) {
      write(paste('WARNING: removed ', length(S_Delta) - old_len, 
                  'NaN or Inf values from S_Delta\n'), file=stderr())
    }


    S_Delta_boot <- bootstrap(S_Delta)

    cat(descr, nodecount, 
        format(mean(avg_path_length), digits=3, nsmall=2),
        format(mean(avg_path_length_rand), digits=3, nsmall=2),
        format(round(cc, digits=5), digits=6, nsmall=5),
        format(round(mean(cc_rand), digits=5), digits=6, nsmall=5),
        format(S_Delta_boot$mean, digits=3, nsmall=2),
        format(S_Delta_boot$lower, digits=3, nsmall=2),
        format(S_Delta_boot$upper, digits=3, nsmall=2),
        sep=' & ')
    cat('\\\\\n')
}
cat('\\hline\n')
cat('\\end{tabular}\n')
