#!/usr/bin/Rscript
#
# File:    makeReducedBioNetworksGraphStatsSummary.R
# Author:  Alex Stivala
# Created: March 2017
#
# Read in recued set (those we have models for)
#  of biological graphs and produce average statistics
# (components, mean degree, density, global clustering coefficient)
# for the samples.
#
#
# The names of the graphs are harcoded in this script.

# Usage:
# 
# Rscript makeReducedBioNetworksGraphStatsSummary.R
#

library(igraph)

options(scipen=999) # force decimal not scientific notation

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
# main
#

graphs <- c(
    "../yeast/model1/yeast_edgelist.txt",
    "../hippie/model1/hippie_ppi_high_edgelist.txt",
    "../ecoli/estimnetdirected/ecoli1_arclist.txt",
    "../alon_yeast_transcription/yeast_transcription_arclist.txt",
    "../cook_celegans/CelegansMaleChem/GMaleChem_arclist.txt",
    "../lolog_estimations/kaiser_celegans277/celegans277.net",
    "../ergm_tapered_estimations/fly_medulla/drosophila_medulla_1_named_arclist.txt"
    )

# description of graph must line up with filename pattern above
descrs <- c(
    "Yeast PPI",
    "Human PPI (HIPPIE)",
    "Alon \\textit{E.~coli} regulatory",
    "Alon yeast regulatory",
    "Cook \\textit{C.~elegans} connectome",
    "Kaiser \\textit{C.~elegans} neural",  
    "\\textit{Drosophila} medulla (named)"
    )

cat('\\begin{tabular}{llrrrrrr}\n')
cat('\\hline\n')
cat('Network & Directed & N  &   Components &  Size of largest &Mean degree     &    Density & Clustering   \\\\\n')
cat('        &          &    &              &  component       &                &            &  coefficient  \\\\\n')
cat('\\hline\n')
for (i in 1:length(graphs)) {
    if (grepl("\\.graphml$", graphs[i])) {
        g <- read.graph(graphs[i], format="graphml")
        g <- as.undirected(g) # only for mouse retina
    } else {
        g <- read.graph(graphs[i], format="pajek")
    }
    g <- simplify(g)
    descr <- descrs[i]
    nodecount <-  vcount(g)
    components <- length(decompose.graph(g))
    giant_component_N <- vcount(giant.component(g))
    meanindegree <-  mean(degree(g), mode='in')
    meanoutdegree <-  mean(degree(g), mode='out')
    stopifnot(meanindegree == meanoutdegree)
    meandegree <- meanoutdegree
    density <-  graph.density(g)
#    avg_path_length_directed <- average.path.length(g, directed=TRUE)
#    avg_path_length_undirected <- average.path.length(g, directed=FALSE)
    cc <- transitivity(g, type="global")

    cat(descr,  ifelse(is.directed(g), "Y", "N"),
        nodecount,  components, giant_component_N,
        format(meandegree, digits=3, nsmall=2),
        format(round(density, digits=5), digits=6, nsmall=5),
        format(round(cc, digits=5), digits=6, nsmall=5),
#        ifelse(!is.directed(g), "--", format(avg_path_length_directed, digits=3, nsmall=2)),
#        format(avg_path_length_undirected, digits=3, nsmall=2),
        sep=' & ')
    cat('\\\\\n')
}
cat('\\hline\n')
cat('\\end{tabular}\n')
