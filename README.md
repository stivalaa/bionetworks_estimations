# Data and scripts for "Testing biological network motif significance with exponential random graph models"

Analysis of the structure of biological networks often uses statistical tests to establish the over-representation of motifs, which are thought to be important building blocks of such networks related to their biological functions. However, there is disagreement on the statistical significance of these motifs and the methods used to determine it. Exponential random graph models (ERGMs) are a class of statistical model that overcome many of the shortcomings of commonly used methods for testing the statistical significance of motifs. ERGMs were first introduced into the bioinformatics literature over ten years ago but have had limited application due to the practical difficulty of estimating model parameters. Advances in estimation algorithms now afford analysis of much larger networks in practical time. We illustrate the application of these methods to both an undirected protein-protein interaction (PPI) network and directed regulatory and neural networks. We confirm some, but not all, prior results as to motif significance in these data sets.

## Software

The data and scripts in this repository were imported from the ergm_bionetworks_data_scripts.tar.gz archive available from https://sites.google.com/site/alexdstivala/home/ergm_bionetworks.

The EstimNetDirected software for estimating ERGM parameters for directed networks is available from https://sites.google.com/site/alexdstivala/home/estimnetdirected or GitHub: https://github.com/stivalaa/EstimNetDirected.

The Estimnet software for estimating ERGM parameters for undirected networks is available from http://www.estimnet.org/.

## References
Stivala, A. & Lomi, A. (2020). Testing biological network motif significance with exponential random graph models. arXiv preprint arXiv:2001.11125 https://arxiv.org/abs/2001.11125
