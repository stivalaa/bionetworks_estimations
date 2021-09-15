#!/usr/bin/Rscript
#
# File:    getHippiePPIhighConfidenceEdgelist.R
# Author:  Alex Stivala
# Created: June 2021
#
#
# Get human protein interaction network from HIPPIE  and wrte files for
# SMNet estimation.
#
# Refs for HIPPIE are:
#
#    Schaefer MH, Fontaine J-F, Vinayagam A, Porras P, Wanker EE, et al. (2012) HIPPIE: Integrating Protein Interaction Networks with Experiment Based Quality Scores. PLoS ONE, 7(2): e31826 
#
#    Schaefer MH, Lopes TJS, Mah N, Shoemaker JE, Matsuoka Y, et al. (2013) Adding Protein Context to the Human Protein-Protein Interaction Network to Reveal Meaningful Interactions. PLoS Computational Biology, 9(1): e1002860 
#
#    Suratanee A, Schaefer MH, Betts M, Soons Z, Mannsperger H, et al. (2014) Characterizing Protein Interactions Employing a Genome-Wide siRNA Cellular Phenotyping Screen. PLoS Computational Biology, 10.9: e1003814 
#
#    Alanis-Lobato G, Andrade-Navarro MA, & Schaefer MH. (2016). HIPPIE v2.0: enhancing meaningfulness and reliability of protein-protein interaction networks. Nucleic Acids Research, gkw985
#
# Using current version is v2.2 last updated 02/14/19
# downloaded from http://cbdm.uni-mainz.de/hippie/ on 12 June 2021
#
# Usage:
# 
# Rscript getHippiePPIhighConfidenceEdgelist.R 
#
# Output files are (WARNING: overwritten in cwd):
#
#    sampledesc.txt		- referred to in setting.txt, names other files
#    hippie_ppi_high_edgelist.txt - edge list Pajek format
#    hippie_ppi_high_zones.txt    - snowball sample zones (all 0 full network)
#    hippie_ppi_high_actors.txt   - node attributes
#

library(igraph)

# read in R source file from directory where this script is located
#http://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
source_local <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
  source(paste(base_dir, fname, sep=.Platform$file.sep))
}

source_local('snowballSample.R')

# 
# write_subactors_file_with_attr() - write subacctors file in parallel spnet format
#
# Parameters:
#     filename - filename to write to (warning: overwritten)
#     g - igrpah graph object
#
# Return value:
#    None
#
# See documetnation of this file in snowball.c readSubactorsFile()
# (format written by showActorsFile()).
#
write_subactors_file_with_attr <- function(filename, g) {
  # TODO specific to yeast data, make this a reusable function and put in
  # snowballSample.R

  num_bin_attr = 0  
  num_cont_attr = 0
  num_cat_attr = 0
  f <- file(filename, open="wt")
  cat("* Actors ", vcount(g), "\n", file=f)
  cat("* Number of Binary Attributes = ", num_bin_attr, "\n", file=f)
  cat("* Number of Continuous Attributes = ", num_cont_attr, "\n", file=f)
  cat("* Number of Categorical Attributes = ", num_cat_attr, "\n", file=f)
  cat("Binary Attributes:\n", file=f)
  #cat("id Manager\n", file=f) 
  cat("id\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_bin_attr) {
      cat (" ", file=f)
#      cat((if (V(g)$Manager[i] == "Y") "1" else "0"), file=f)
    }
    cat("\n", file=f)
  }
  cat("Continuous Attributes:\n", file=f)
  #cat("id EgonetDegree CommOnlyDegree Comments Recommendations Views BlogCmtCnt BlogCnt ForumRepCnt ForumCnt\n", file=f) 
  cat("id \n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_cont_attr) {
#      cat (" ", file=f)
#      # output cont attr j value for node i
#      value <- switch(j,
#        V(g)$EgonetDegree[i],
#        V(g)$CommOnlyDegree[i],
#        V(g)$Comments[i],
#        V(g)$Recommendations[i],
#        V(g)$Views[i],
#        V(g)$BlogCmtCnt[i],
#        V(g)$BlogCnt[i],
#        V(g)$ForumRepCnt[i],
#        V(g)$ForumCnt[i]
#      )
#      cat(value, file=f)
#    }
    cat("\n", file=f)
  }
  cat("Categorical Attributes:\n", file=f)
#  cat("id class\n", file=f)
  cat("id \n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_cat_attr) {
#      cat (" ", file=f)
#      # output cat attr j value for node i
#      if (j == 1) {
#        cat(V(g)$class_cat[i], file=f)
#      } 
#      else {
#        stop(paste("unknown attribute j = ", j))
#      }
#    }
    cat("\n", file=f)
  }
  close(f)
}


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: getHippiPPIhighConfidenceEdgelist.R\n")
  quit(save="no")
}

hippie <- read.table('/home/stivala/HIPPIE/hippie_current.txt', header=F, sep='\t', stringsAsFactors=F)
#http://cbdm-01.zdv.uni-mainz.de/~mschaefer/hippie/information.php).
names(hippie) <- c('Uniprot1','EntrezGene1','Uniprot2','EntrezGene2','score','description')
g <- graph_from_data_frame(hippie[c("Uniprot1","Uniprot2","score")])
summary(g)
summary(E(g)$score)
g <- as.undirected(g, mode='collapse', edge.attr.comb=list(score="max"))
summary(g)
summary(E(g)$score)
g <- simplify(g, remove.multiple = TRUE, remove.loops = TRUE, edge.attr.comb=list(score="max"))
summary(g)
summary(E(g)$score)

g_high <- subgraph.edges(g, E(g)[[score >= 0.70]]) # third quartile
summary(g_high)
summary(E(g_high)$score)

g <- g_high

## remove nodes that have blank name
g <- induced.subgraph(g, V(g)[which(V(g)$name != "")])
summary(g)


# write vertex names/attributes for future ref (save stdout to file to keep)
print(V(g)$name)


cat(vcount(g), "hippie_ppi_high_zones.txt", "hippie_ppi_high_edgelist.txt", "hippie_ppi_high_actors.txt", file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file("hippie_ppi_high_zones.txt", rep.int(0, vcount(g)))
write.graph(g, "hippie_ppi_high_edgelist.txt", format="pajek")
write_subactors_file_with_attr("hippie_ppi_high_actors.txt", g)


