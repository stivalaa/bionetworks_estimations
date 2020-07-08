#!/usr/bin/Rscript
#
# File:    convertMouseRetinaToSMNetFormat.R
# Author:  Alex Stivala
# Created: May 2019
#
# Read the GraphML file for mouse retina
# neurons downloaded from 
# https://neurodata.io/project/connectomes/
# and write Pajek arc list format.
#
# Citation for data is
#
#  M. Helmstaedter et al., "Connectomic reconstruction of the inner plexiform layer in the mouse retina." Nature 500, 168-174 (2013) Link
#
# Usage:
# 
# Rscript convertMouseRetinaToSMNetFormat.R 
#
# NB using simplify to remove multiedges and self-edges reduces
# original 577350 arcs to only 90811 arcs. This is entirely
# due to multiple edges; there are no self-loops.
#
# Output files (WARNING overwritten)
#    mouse_retina_edgelist.txt         - edge list Pajek format
#    mouse_retina_zones.txt            - snowball sample zones (all 0 full network)
#    mouse_retina_nodeattrs           - node attributes
#    sampledesc.txt                   - index to above files
#
#

library(igraph)
# no longer seems to have if_else: library(dplyr) # massive overkill but needed for if_else since ifelse does not work for charcter data types

CAT_NA_VALUE <- 99999 # special value for NA on categorical attribute must match graphArray.c


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
# write_zone_file() - write zone file in parallel spnet (Pajek .clu) file format
#
# Parameters:
#    filename - filename to write to (warning: overwritten)
#    zones  - vector of snowball zones (waves) 0..n (0 for seed node)
#             elemetn i of the vector corresponds to node i of graph (1..N)
#
# Return value:
#    None.
#
write_zone_file <- function(filename, zones) {
  f <- file(filename, open="wt")
  cat('*vertices ', length(zones), '\n', file=f)
  write.table(zones, file=f, row.names=F, col.names=F)
  close(f)
}

# 
# write_subnodeattrs_file_with_attr() - write subacctors file in parallel spnet format
#
# Parameters:
#     filename - filename to write to (warning: overwritten)
#     g - igrpah graph object
#
# Return value:
#    None
#
# See documetnation of this file in snowball.c readSubnodeattrsFile()
# (format written by showActorsFile()).
#
write_subnodeattrs_file_with_attr <- function(filename, g) {

  num_bin_attr = 0
  num_cont_attr = 3
  num_cat_attr = 3
  f <- file(filename, open="wt")
  cat("* Actors ", vcount(g), "\n", file=f)
  cat("* Number of Binary Attributes = ", num_bin_attr, "\n", file=f)
  cat("* Number of Continuous Attributes = ", num_cont_attr, "\n", file=f)
  cat("* Number of Categorical Attributes = ", num_cat_attr, "\n", file=f)
  cat("Binary Attributes:\n", file=f)
  #cat("id Attribute1\n", file=f) 
  cat("id\n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
#    for (j in 1:num_bin_attr) {
#      cat (" ", file=f)
#      cat((if (V(g)$binattr[i] == 1) "1" else "0"), file=f)
#    }
    cat("\n", file=f)
  }
  cat("Continuous Attributes:\n", file=f)
  cat("id x y z \n", file=f) 
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_cont_attr) {
      cat (" ", file=f)
      # output cont attr j value for node i
      value <- switch(j,
        V(g)$x[i],
        V(g)$y[i],
        V(g)$z[i]
      )
      cat(value, file=f)
    }
    cat("\n", file=f)
  }
  cat("Categorical Attributes:\n", file=f)
  cat("id designation volgyi_type macneil_type\n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_cat_attr) {
      cat (" ", file=f)
      # output cat attr j value for node i
      if (j == 1) {
        cat(as.numeric(V(g)$designation[i]), file=f)
      }  else if (j == 2) {
        cat(as.numeric(V(g)$volgyi_type[i]), file=f)
      } else if (j == 3) {
        cat(as.numeric(V(g)$macneil_type[i]), file=f)
      }else {
        stop(paste("unknown attribute j = ", j))
      }
    }
    cat("\n", file=f)
  }
  close(f)
}

################################### main ###################################

args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: convertMouseRetinaToSMNetFormat.R\n")
  quit(save="no")
}

g <- read.graph("mouse_retina_1.graphml", format="graphml")
g <- as.undirected(g)
summary(g)
g <- simplify(g , remove.multiple = TRUE, remove.loops = TRUE)
summary(g)


g <- giant.component(g)
summary(g)

network_name <- 'mouse_retina'
zonefilename <- paste(network_name, "_zones.txt", sep="")
edgelistfilename <- paste(network_name, "_edgelist.txt", sep="")
nodeattrsfilename <- paste(network_name, "_nodeattrs.txt", sep="")

cat(vcount(g), zonefilename, edgelistfilename, nodeattrsfilename,
    file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file(zonefilename, rep.int(0, vcount(g)))
write.graph(g, edgelistfilename, format="pajek")

##
## categorical attributes
##

catattr <- data.frame(designation = V(g)$designation,
                      volgyi_type = V(g)$volgyi_type,
                      macneil_type = V(g)$macneil_type)
# note have to use dplyr::if_else as ifelse forces everything into integer
# https://stackoverflow.com/questions/6668963/how-to-prevent-ifelse-from-turning-date-objects-into-numeric-objects
# why is everything in R always so difficult?
# also does not work as if_else in dplyr no longer seems to exist on the system I'm using??!?
# why is everying in R always so difficult?!?!!?!?
#catattr$designation <- if_else(catattr$designation == "NA", "NA", catattr$designation)
#catattr$volgyi_type <- if_else(catattr$volgyi_type == "NA" | catattr$volgyi_type == "", "NA", catattr$volgyi_type)
#catattr$macneil_type <- if_else(catattr$macneil_type == "NA" | catattr$macneil_type == "", "NA", catattr$macneil_type)
# so manually do it with lambda expression instead:
# (also note need to put as.character() everywhere, who knows why in R?)
setNA <- function(x) { if (x == "NA" | x == "") as.character(NA) else as.character(x) }
catattr$designation <- sapply(catattr$designation, setNA)
catattr$volgyi_type <- sapply(catattr$volgyi_type, setNA)
catattr$macneil_type <- sapply(catattr$macneil_type, setNA)

catattr$designation <- factor(catattr$designation)
print(levels(catattr$designation))
catattr$volgyi_type <- factor(catattr$volgyi_type)
print(levels(catattr$volgyi_type))
catattr$macneil_type <- factor(catattr$macneil_type)
print(levels(catattr$macneil_type))
catattr$designation <- as.numeric(catattr$designation)
catattr$volgyi_type <- as.numeric(catattr$volgyi_type)
catattr$macneil_type <- as.numeric(catattr$macneil_type)

V(g)$designation <- ifelse(is.na(catattr$designation), CAT_NA_VALUE,
                                                       catattr$designation)
V(g)$volgyi_type <- ifelse(is.na(catattr$volgyi_type), CAT_NA_VALUE,
                                                       catattr$volgyi_type)
V(g)$macneil_type <- ifelse(is.na(catattr$macneil_type), CAT_NA_VALUE,
                                                       catattr$macneil_type)

##
## write attributes
##
write_subnodeattrs_file_with_attr(nodeattrsfilename, g)

