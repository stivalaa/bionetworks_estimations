# Data and scripts for "Testing biological network motif significance with exponential random graph models"

Analysis of the structure of biological networks often uses statistical tests to establish the over-representation of motifs, which are thought to be important building blocks of such networks, related to their biological functions. However, there is disagreement as to the statistical significance of these motifs, and there are potential problems with standard methods for estimating this significance. Exponential random graph models (ERGMs) are a class of statistical model that can overcome some of the shortcomings of commonly used methods for testing the statistical significance of motifs. ERGMs were first introduced into the bioinformatics literature over ten years ago but have had limited application to biological networks, possibly due to the practical difficulty of estimating model parameters. Advances in estimation algorithms now afford analysis of much larger networks in practical time. We illustrate the application of ERGM to both an undirected protein-protein interaction (PPI) network and directed gene regulatory networks. ERGM models indicate over-representation of triangles in the PPI network, and confirm results from previous research as to over-representation of transitive triangles (feed-forward loop) in an E. coli and a yeast regulatory network. We also confirm, using ERGMs, previous research showing that under-representation of the cyclic triangle (feedback loop) can be explained as a consequence of other topological features.


## Software

The data and scripts in this repository were imported from the ergm_bionetworks_data_scripts.tar.gz archive available from https://sites.google.com/site/alexdstivala/home/ergm_bionetworks.

The EstimNetDirected software for estimating ERGM parameters for directed networks is available from https://sites.google.com/site/alexdstivala/home/estimnetdirected or GitHub: https://github.com/stivalaa/EstimNetDirected.

The Estimnet software for estimating ERGM parameters for undirected networks is available from http://www.estimnet.org/.

## References
Stivala, A. & Lomi, A. (2021). Testing biological network motif significance with exponential random graph models. arXiv preprint arXiv:2001.11125 https://arxiv.org/abs/2001.11125
