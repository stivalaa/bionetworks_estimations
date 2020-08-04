# Data and scripts for "Testing biological network motif significance with exponential random graph models"

Background: Analysis of the structure of biological networks often
uses statistical tests to establish the over-representation of motifs,
which are thought to be important building blocks of such networks
related to their biological functions. However, there is disagreement
on the statistical significance of these motifs and the methods used
to determine it. Exponential random graph models (ERGMs) are a class
of statistical model that can overcome some of the shortcomings of
commonly used methods for testing the statistical significance of
motifs. ERGMs were first introduced into the bioinformatics literature
over ten years ago but have had limited application, possibly due to
the practical difficulty of estimating model parameters. Advances in
estimation algorithms now afford analysis of much larger networks in
practical time.

Results: We illustrate the application of these methods to both an
undirected protein-protein interaction (PPI) network and directed gene
regulatory networks.  We confirm the over-representation of triangles
in the PPI network and transitive triangles (feed-forward loop) in an
E. coli regulatory network, but not in a yeast regulatory network. We
also confirm using this method previous research showing that
under-representation of the cyclic triangle (feedback loop) can be
explained as a consequence of other topological features.

Conclusion: ERGMs allow the over- or under-representation of multiple
non-independent structural configurations to be tested simultaneously
in a single model. This can overcome some of the problems recently
identified in mainstream methods for motif identification,
specifically assumptions of normally distributed motif frequencies and
independence of motifs.

Keywords: ERGM; Exponential random graph model; Network motifs;
Gene regulatory networks


## Software

The data and scripts in this repository were imported from the ergm_bionetworks_data_scripts.tar.gz archive available from https://sites.google.com/site/alexdstivala/home/ergm_bionetworks.

The EstimNetDirected software for estimating ERGM parameters for directed networks is available from https://sites.google.com/site/alexdstivala/home/estimnetdirected or GitHub: https://github.com/stivalaa/EstimNetDirected.

The Estimnet software for estimating ERGM parameters for undirected networks is available from http://www.estimnet.org/.

## References
Stivala, A. & Lomi, A. (2020). Testing biological network motif significance with exponential random graph models. arXiv preprint arXiv:2001.11125 https://arxiv.org/abs/2001.11125
