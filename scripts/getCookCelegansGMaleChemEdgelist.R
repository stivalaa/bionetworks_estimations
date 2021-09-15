#!/usr/bin/Rscript
#
# File:    getCookCelegansGMaleChemEdgelist.R
# Author:  Alex Stivala
# Created: September 2021
#
#
# Get C. elegans whole connectome (male, chemical [directed]) from 
# MATLAB ready data provided by 
# SMNet estimation.
#
# Citation for data is:
#
#  Cook, S. J., Jarrell, T. A., Brittin, C. A., Wang, Y., Bloniarz, A. E., Yakovlev, M. A., ... & Emmons, S. W. (2019). Whole-animal connectomes of both Caenorhabditis elegans sexes. Nature, 571(7763), 63-71.
#
#
# Exact data source is from:
#
# C. elegans connectome tables in MATLAB-ready format, by Kamal Premaratne, University of Miami
# Supplementary Information 5 of Cook et al., 2019. Excel connectivity tables in MATLAB-ready format. [zip]
# "Premaratne MATLAB-ready files.zip" downloaded 6/9/21 from: https://wormwiring.org/matlab%20scripts/Premaratne%20MATLAB-ready%20files%20.zip
#(constructed from .SI 5 Connectome adjacency matrices, corrected July 2020.xlsx.)
#
# Usage:
# 
# Rscript getCookCelegansGMaleChemEdgelist.R 
#
# Input file is (extracted from the zip file above) MATLAB data
#    GMaleChem.mat
#
# Output files are (WARNING: overwritten in cwd):
#    GMaleChem_arclist.txt
#
# Citation for R.matlab package is:
#  @Manual{,
#    title = {R.matlab: Read and Write MAT Files and Call MATLAB from Within R},
#    author = {Henrik Bengtsson},
#    year = {2018},
#    note = {R package version 3.6.2},
#    url = {https://CRAN.R-project.org/package=R.matlab},
#  }
#
#
# Citation for igraph is:
# @Article{,
#    title = {The igraph software package for complex network research},
#    author = {Gabor Csardi and Tamas Nepusz},
#    journal = {InterJournal},
#    volume = {Complex Systems},
#    pages = {1695},
#    year = {2006},
#    url = {https://igraph.org},
#  }
#

library(R.matlab)
library(igraph)

dat <- readMat('GMaleChem.mat')
g <- graph_from_adjacency_matrix(as.matrix(dat$AMaleChem))
summary(g)
g <- simplify(g)
summary(g)


write.graph(g,'GMaleChem_arclist.txt',format='pajek')

