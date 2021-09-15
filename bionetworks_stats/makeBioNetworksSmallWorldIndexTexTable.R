#!/usr/bin/Rscript
#
# File:    makeBioNetworksSmallWorldIndexTexTable.R
# Author:  Alex Stivala
# Created: May 2017
#
# Read in all biological network data and make Latex table with graph
# small world statistic SWI as per Neal 2017 "How small is it? Comparing 
# indices of small worldliness" Network Science 5(1):30-44
#
# Also can compute the double-graph normalized index omega' from
# Telesford, Q. K., Joyce, K. E., Hayasaka, S., Burdette, J. H., &
# Laurienti, P. J. (2011). The ubiquity of small-world networks. 
# Brain connectivity, 1(5), 367-375.
# instead
#
# Network file locations are hardcoded here.
#
# Usage:
# 
# Rscript makeBioNetworksSmallWorldIndexTexTable.R [-c] [-o]
#
# if -c is specified, use only the giant component of the network
# if -o is specified, onlu include nodes with degree > 1 in computing c.c.
# if -w is specified, compute the double-graph normalized index omeg' instead

library(igraph)
library(optparse)


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
# main
#


option_list = list(
    make_option(c("-c", "--giant-component"), action="store_true",
                dest="use_giant_component",
                default=FALSE, help="Use only giant component"),
    make_option( c("-o", "--omit-degree-1-on-cc"), action="store_true",
                default=FALSE, dest="omit_deg1_cc",
                help="Omit degree 1 nodes in computing clustering coefficient"),
    make_option(c("-w", "--omega-prime"), action="store_true", 
                default=FALSE, dest="compute_omega",
                help="Compute omega' instead of SWI")
    )
opt <- parse_args(OptionParser(option_list=option_list))
use_giant_component <- opt$use_giant_component
omit_deg1_cc <- opt$omit_deg1_cc
compute_omega <- opt$compute_omega




cat('\\begin{tabular}{lrrrrrrrr}\n')
cat('\\hline\n')
if (compute_omega) {
  cat('Network & N  & $L_{\\mathrm{g}}$ & $L_{\\mathrm{r}}$ & $L_{\\mathrm{l}}$ & $C^\\ast_{\\mathrm{g}}$ & $C^\\ast_{\\mathrm{r}}$ & $C^\\ast_{\\mathrm{l}}$ &  $\\omega\'$ \\\\\n')
} else {
  cat('Network & N  & $L_{\\mathrm{g}}$ & $L_{\\mathrm{r}}$ & $L_{\\mathrm{l}}$ & $C^\\ast_{\\mathrm{g}}$ & $C^\\ast_{\\mathrm{r}}$ & $C^\\ast_{\\mathrm{l}}$ &  SWI \\\\\n')
}
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
#    cc <- transitivity(g, type="global") #XXX
#    cc <- mean(transitivity(g, type="local")) # gets NaN for isolates
    ccs <- transitivity(g, type="local")
    # NB when using local transitivity, can have NaN for nodes with
    # degree < 2. So we omit these, and in the end this is exactly
    # the same as the omi_deg1_cc option anyway...
    # using the global transitivity prevents this problem but was defined
    # originally using local
    if (omit_deg1_cc) { 
      # only compute clustering coefficient for nodes wiht degree>1
      # as per Arabidopsis network paper Science 333,601 (2011) SOM Fig S6
      ccs <- ccs[which(degree(g) > 1)]
      stopifnot(all(!is.nan(ccs)))
    } else {
      ccs <- ccs[which(!is.nan(ccs))]
    }
    cc <- mean(ccs)
    
    k <- mean(degree(g))
    n <- nodecount

    # approximations for cc and avg path length 
    # for sparse random and ring lattice graphs 
    # from Neal (2017) eqns (6)-(9)
    cc_rand <- k/n
    avg_path_length_rand <- log(n) / log(k)
    avg_path_length_lattice <- n / (2*k)
    cc_lattice <- (3*(k-2)) / (4*(k-1))

    # SWI as defined by Neal (2017) eqn (5)
    swi <- ((avg_path_length - avg_path_length_lattice) / 
            (avg_path_length_rand - avg_path_length_lattice)) *
           ((cc - cc_rand) / (cc_lattice - cc_rand))

    # omega as defined by Telesford et al (2011) (also Neal 2017 p. 33)
    omega <- (avg_path_length_rand / avg_path_length) - (cc / cc_lattice)
    omega_prime <- 1 - abs(omega)

    if (compute_omega) {
      sw_index_value <- omega_prime
    } else  {
      sw_index_value <- swi
    }

    cat(descr, nodecount, 
        format(avg_path_length, digits=3, nsmall=2),
        format(avg_path_length_rand, digits=3, nsmall=2),
        format(avg_path_length_lattice, digits=3, nsmall=2),
        format(round(cc, digits=3), digits=4, nsmall=3),
        format(round(cc_rand, digits=3), digits=4, nsmall=3),
        format(round(cc_lattice, digits=3), digits=4, nsmall=3),
        format(round(sw_index_value, digits=3), digits=4, nsmall=3),
        sep=' & ')
    cat('\\\\\n')
}
cat('\\hline\n')
cat('\\end{tabular}\n')
