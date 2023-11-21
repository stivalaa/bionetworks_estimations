#!/usr/bin/env Rscript
###
### File:    convert_Celegans_277_network_to_pajek_format.R
### Author:  Alex Stivala
### Created: November 2023
###
### Load the Kaiser C. elegans 277 node neural network data
### and convert to Pajek format.
###
### Writes output file celegans277.net in cwd (WARNING: overwrites).
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

source('load_celegans_277_data.R')

dat <- load_celegans_277_data()
write.graph(dat$g, 'celegans277.net', format='pajek')

