# Data and scripts for "Testing biological network motif significance with exponential random graph models" (2021) and "New network models facilitate biological network motif statistical significance testing" (2023)

## Testing biological network motif significance with exponential random graph models
Analysis of the structure of biological networks often uses statistical tests to establish the over-representation of motifs, which are thought to be important building blocks of such networks, related to their biological functions. However, there is disagreement as to the statistical significance of these motifs, and there are potential problems with standard methods for estimating this significance. Exponential random graph models (ERGMs) are a class of statistical model that can overcome some of the shortcomings of commonly used methods for testing the statistical significance of motifs. ERGMs were first introduced into the bioinformatics literature over ten years ago but have had limited application to biological networks, possibly due to the practical difficulty of estimating model parameters. Advances in estimation algorithms now afford analysis of much larger networks in practical time. We illustrate the application of ERGM to both an undirected protein-protein interaction (PPI) network and directed gene regulatory networks. ERGM models indicate over-representation of triangles in the PPI network, and confirm results from previous research as to over-representation of transitive triangles (feed-forward loop) in an E. coli and a yeast regulatory network. We also confirm, using ERGMs, previous research showing that under-representation of the cyclic triangle (feedback loop) can be explained as a consequence of other topological features.


## New network models facilitate analysis of biological networks

## Software

The data and scripts in this repository were originally imported from the ergm_bionetworks_data_scripts.tar.gz archive available from https://sites.google.com/site/alexdstivala/home/ergm_bionetworks.

The EstimNetDirected software for estimating ERGM parameters for directed networks (which now also handles undirected and bipartite networks) is available from https://sites.google.com/site/alexdstivala/home/estimnetdirected or GitHub: https://github.com/stivalaa/EstimNetDirected.

The older Estimnet software for estimating ERGM parameters for undirected networks is available from https://web.archive.org/web/20221007014617/http://www.estimnet.org/. (EstimNetDirect can now, despite the name, also estimated ERGM models for undirected and bipartite networks).

The [statnet](https://statnet.org/) software collection of R packages is available from CRAN at https://cran.r-project.org/web/packages/statnet/index.html

The latent order logistic model (LOLOG) R package is available from CRAN at https://cran.r-project.org/web/packages/lolog/index.html

The ergm.tapered R package is available via GitHub at https://github.com/statnet/ergm.tapered


## References

Stivala, A. (2023). New network models facilitate biological network motif statistical significance testing. (Manuscript in preparation)

Stivala, A. & Lomi, A. (2021). Testing biological network motif significance with exponential random graph models. _Applied Network Science_ 6:91. https://doi.org/10.1007/s41109-021-00434-y

