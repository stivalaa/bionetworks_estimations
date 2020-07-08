#!/usr/bin/Rscript
#
# File:    makeDirectedBioNetworksGraphStatsSummary.R
# Author:  Alex Stivala
# Created: March 2017
#
# Read in all the biological graphs and produce average statistics
# (components, mean degree, density, global clustering coefficient)
# for the samples.
#
#
# The names of the graphs are harcoded in this script.

# Usage:
# 
# Rscript makeDirectedBioNetworksGraphStatsSummary.R
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
    "../undirected/arabidopsis_interactome/arabadopsis_interactome_edgelist.txt",
    "../undirected/yeast/yeast_edgelist.txt",
    "../undirected/human_interactome/human_interactome_edgelist.txt",
    "../undirected/worm_ppi/worm_ppi_edgelist.txt",
    "../ecoli/estimnetdirected/ecoli1_arclist.txt",
    "../gerstein_ecoli/ecoli_arclist.txt",
    "../alon_yeast_transcription/yeast_transcription_arclist.txt",
    "../gerstein_yeast/yeast_arclist.txt",
    "../fly_medulla/fly_medulla_arclist.txt",
    "../mouse_retina_undirected/mouse_retina_1.graphml" # not really directed
    )

# description of graph must line up with filename pattern above
descrs <- c(
    "\\textit{A.~thaliana} PPI",
    "Yeast PPI",
    "Human PPI",
    "\\textit{C. elegans} PPI",
    "Alon \\textit{E.~coli} regulatory",
    "Gerstein \\textit{E.~coli} regulatory",
    "Alon yeast regulatory",
    "Gerstein yeast regulatory",
    "\\textit{Drosophila} optic medulla",
    "Mouse retina neural network" # not really directed
    )

cat('\\begin{tabular}{llrrrrrrrr}\n')
cat('\\hline\n')
cat('Network & Directed & N  &   Components &  Size of largest &Mean degree     &    Density & Clustering  & \\multicolumn{2}{c}{Average path length}\\\\\n')
cat('        &          &    &              &  component       &                &            &  coefficient & directed & undirected \\\\\n')
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
    avg_path_length_directed <- average.path.length(g, directed=TRUE)
    avg_path_length_undirected <- average.path.length(g, directed=FALSE)
    cc <- transitivity(g, type="global")

    cat(descr,  ifelse(is.directed(g), "Y", "N"),
        nodecount,  components, giant_component_N,
        format(meandegree, digits=3, nsmall=2),
        format(round(density, digits=5), digits=6, nsmall=5),
        format(round(cc, digits=5), digits=6, nsmall=5),
        ifelse(!is.directed(g), "--", format(avg_path_length_directed, digits=3, nsmall=2)),
        format(avg_path_length_undirected, digits=3, nsmall=2),
        sep=' & ')
    cat('\\\\\n')
}
cat('\\hline\n')
cat('\\end{tabular}\n')
