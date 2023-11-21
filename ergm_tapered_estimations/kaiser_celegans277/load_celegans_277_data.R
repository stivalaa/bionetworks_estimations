###
### File:    load_celegans_277_data.R
### Author:  Alex Stivala
### Created: November 2023
###
### Load the Kaiser C. elegans 277 node neural network data
### including neuronal co-ordinates and birth times.
###
### Citations for data:
###
###  Varier S, Kaiser M (2011) Neural development features:
###  Spatio-temporal developme nt of the C. elegans neuronal
###  network. PLoS Computational Biology 7:e1001044 (PD F)
###
###  Kaiser M, Hilgetag CC (2006) Non-Optimal Component Placement, but
###  Short Processing Paths, due to Long-Distance Projections in Neural
###  Systems. PLoS Computational Biology 2:e95 (PDF) 
###
###  Choe Y, McCormick BH, Koh W (2004) Network connectivity analysis on
###  the temporally augmented C. elegans web: A pilot study. Society of
###  Neuroscience Abstracts 30:921.9.
###
###

library(igraph)

##
## Return named list with objects graph and celegans277_distmatrix:
##      graph: igraph graph object (directed) with node attributes:
##        name      - neuron label
##        label     - neuron label (same as name but name is special for igraph)
##        birthtime - neuronal birth time (minutes)
##      celegans277_distmatrix - dist object of Euclidean distances (mm)
##                               between all pairs of neurons
##
load_celegans_277_data <- function() {
  celegans277adjmat <- as.matrix(read.csv('celegans277matrix.csv',header=FALSE))
  g <- graph_from_adjacency_matrix(celegans277adjmat)
  summary(g)
  g <- simplify(g, remove.loops=TRUE, remove.multiple=TRUE)
  summary(g)
  
  celegans277positions <- read.csv('celegans277positions.csv', header=FALSE)
  system.time( celegans277_distmatrix <- as.matrix(dist(celegans277positions)) )
  
  ## Read neuron labels and set them as node names
  label <- read.table('celegans277labels.csv', header=FALSE,
                       stringsAsFactors=FALSE)
  V(g)$name <- label$V1
  V(g)$label <- label$V1
  
  ## Read neuronal birth times (in minutes) derived from Sulston et
  ## al. (1977, 1983) by Varier & Kaiser (2011)
  birthtimes <- read.csv('celegans_neuron_birth_times.csv' , header=F)
  names(birthtimes) <-c('label0','time')
  
  ## Convert names from format in the birth times CSV file where numbers
  ## have leading zeroes e.g. VD02 to those used in labels where they do not
  ## e.g VD2
  #print(birthtimes)#XXX
  birthtimes$label <- sapply(birthtimes$label0,
                             function(s) sub('([A-Z]+)0+([1-9]+)', '\\1\\2', s))
  
  
  summary(g)
  #print(V(g)$label)#XXX
  #print(birthtimes$label)#XXX
  
  ## Annotate nodes with neuronal birth times
  for (v in V(g)) {
    ## getting anyting to work and debugging in R is always an exercise in frustration...
    #print(v)#XXX
    #print(V(g)[v]$label)#XXX
    #print(which(birthtimes$label == V(g)[v]$label))#XXX
    #print(birthtimes[which(birthtimes$label == V(g)[v]$label), "time"])#XXX
    if (length(which(birthtimes$label == V(g)[v]$label)) == 1) {
      g <- set.vertex.attribute(graph = g, name = "birthtime", index = v,
         value = birthtimes[which(birthtimes$label == V(g)[v]$label), "time"])
    } else if (length(which(birthtimes$label == V(g)[v]$label)) == 0){
      cat("WARNING: no birth time for ", V(g)[v]$label, '\n')
    } else {
      write(paste("ERROR: multiple times for ", V(g)[v]$label, '\n'),
            file = stderr())
    }
  }
  warnings()
  summary(V(g)$birthtime)
  
  ## Cannot have NA values for LOLOG vertex order, so set any NA to mean
  ## There is only one, VC6, so we set it to the mean birth time of the other
  ## VC neurons
  stopifnot(length(which(is.na(V(g)$birthtime))) == 1)
  stopifnot(V(g)[which(is.na(V(g)$birthtime))]$label == "VC6")
  vcnodes <- which(substr(V(g)$label, start=1, stop=2) == "VC")
  vctimes <- V(g)[vcnodes]$birthtime
  mean_vctime <- mean(vctimes, na.rm=TRUE) #remove NAs as it includes VC6
  V(g)[which(V(g)$label == "VC6")]$birthtime <- mean_vctime
  cat("set birth time for VC6 to mean VC time ", mean_vctime, "\n")
  summary(V(g)$birthtime)

  return(list(g = g, celegans277_distmatrix = celegans277_distmatrix))
}
