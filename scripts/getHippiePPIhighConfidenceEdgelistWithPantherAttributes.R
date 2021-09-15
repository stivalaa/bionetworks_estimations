#!/usr/bin/Rscript
#
# File:    getHippiePPIhighConfidenceEdgelistWithPantherAttributes.R
# Author:  Alex Stivala
# Created: June 2021
#
#
# Get human protein interaction network from HIPPIE, annotate with attributes
# (speficially, protein subcellular location),  and wrte files for
# SMNet estimation.
# Uses the GOxploreR R package to rank the gene ontology (GO) terms
# for subcellular location from Panther to find the highest ranking 
# one so we have a single attribute not a list.
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
#Citations for PANTHER are:
#
#  Thomas, P. D., Campbell, M. J., Kejariwal, A., Mi, H., Karlak, B., Daverman, R., ... & Narechania, A. (2003). PANTHER: a library of protein families and subfamilies indexed by function. Genome research, 13(9), 2129-2141.
#
#  Mi, H., Muruganujan, A., & Thomas, P. D. (2013). PANTHER in 2013: modeling the evolution of gene function, and other gene attributes, in the context of phylogenetic trees. Nucleic acids research, 41(Database issue), D377–D386. https://doi.org/10.1093/nar/gks1118
#
#  Mi, H., Muruganujan, A., Huang, X., Ebert, D., Mills, C., Guo, X., & Thomas, P. D. (2019). Protocol Update for large-scale genome and gene function analysis with the PANTHER classification system (v. 14.0). Nature protocols, 14(3), 703-721.
#
#  Mi, H., Lazareva-Ulitsky, B., Loo, R., Kejariwal, A., Vandergriff, J., Rabkin, S., ... & Thomas, P. D. (2005). The PANTHER database of protein families, subfamilies, functions and pathways. Nucleic acids research, 33(suppl_1), D284-D288.
#
#  Mi, H., Ebert, D., Muruganujan, A., Mills, C., Albou, L. P., Mushayamaha, T., & Thomas, P. D. (2021). PANTHER version 16: a revised family classification, tree-based classification tool, enhancer regions and extensive API. Nucleic Acids Research, 49(D1), D394-D403.
#
#"How to cite" says to always cite Mi et al. (2021); and for classification
#system, Mi et al. (2019).
#
# Citations for GOxplorerR are:
#
#
#  Kalifa Manjang, Frank Emmert-Streib, Shailesh Tripathi, Olli
#    Yli-Harja and Matthias Dehmer (2021). GOxploreR: Structural
#    Exploration of the Gene Ontology (GO) Knowledge Base. R package
#    version 1.2.1. https://CRAN.R-project.org/package=GOxploreR
#
#  Manjang, K., Tripathi, S., Yli-Harja, O., Dehmer, M., & Emmert-Streib, F. (2020). Graph-based exploitation of gene ontology using GOxploreR for scrutinizing biological significance. Scientific reports, 10:16672
#
#
# Citations for BioConductor (used by GOxplorerR) are:
#
# Orchestrating high-throughput genomic analysis with Bioconductor. W.
#   Huber, V.J. Carey, R. Gentleman, ..., M. Morgan Nature Methods,
#  2015:12, 115.
#
#
#Citations for Gene Ontology (GO) are:
#
#  Ashburner, Michael, Catherine A. Ball, Judith A. Blake, David Botstein, Heather Butler, J. Michael Cherry, Allan P. Davis et al. "Gene ontology: tool for the unification of biology." Nature genetics 25, no. 1 (2000): 25-29.
#
#  The Gene Ontology Consortium, "The Gene Ontology resource: enriching a GOld mine." Nucleic Acids Research 49, no. D1 (2021): D325-D334.
#
# Using PANTHER (Protein ANalysis THrough Evolutionary Relationships) Classification
# files downloaded from
# 
#   http://data.pantherdb.org/ftp/sequence_classifications/current_release/PANTHER_Sequence_Classification_files/PTHR16.0_human
# 
#   (human, Panther version 16.0) on 21 June 2021.
#
#  Mapping of UNIPROT entry names (as used in HIPPIE) to UNIPROT accession
#  numbers (needed as lookup key to UNIPROT data) done by first
#  getting list of unique entry names used in the HIPPIE data:
#  
#    cat hippie_current.txt |awk -F'\t' '{print $1,$3}' | tr ' ' '\n' | tr ',' '\n' | sort|uniq > uniq_uniprot_entrynames.txt
#  
#  then uploading this to the UNIPROT Retrieve / ID mapping service:
#  
#  https://www.uniprot.org/uploadlists/
#  
#  to map from "UniProtKB AC/ID" to  "UniProtKB" and saving as "Mapping Table"
#  to get file uniprot_mapping.tab mapping from the entry names as used in
#  the HIPPIE data to UniProtKB identifiers.
#  
#  Note this method was found on BioStars: https://www.biostars.org/p/479166/
#  
#  Citation for UNIPROT is:
#  
#    The UniProt Consortium "UniProt: The universal protein knowledgebase in 2021." Nucleic Acids Research 49, no. D1 (2021): D480-D489.
#  
#  Citation for BioStars is:
#  
#    Parnell, Laurence D., Pierre Lindenbaum, Khader Shameer, Giovanni Marco Dall'Olio, Daniel C. Swan, Lars Juhl Jensen, Simon J. Cockell et al. "BioStar: an online question & answer resource for the bioinformatics community." PLoS Comput Biol 7, no. 10 (2011): e1002216.
#
#
# Usage:
# 
# Rscript getHippiePPIhighConfidenceEdgelistWithPantherAttributes.R 
#
# Input files are (see README etc. files in directories for more info):
#
#    /home/stivala/HIPPIE/hippie_current.txt  - HIPPIE PPI data
#    /home/stivala/PANTHER/PTHR16.0_human     - PANTHER protein classif. data
#    /home/stivala/HIPPIE/uniprot_mapping.tab - UniProt id mapping table
#
#
# Output files are (WARNING: overwritten in cwd):
#
#    sampledesc.txt		- referred to in setting.txt, names other files
#    hippie_ppi_high_edgelist.txt - edge list Pajek format
#    hippie_ppi_high_zones.txt    - snowball sample zones (all 0 full network)
#    hippie_ppi_high_actors.txt   - node attributes
#    ppi_nodes_panther_annotated.csv - protein info from PANTHER and GOxploreR
#    nodeid_entryname.txt            - map node id number to Uniprot entry name
#
# Uses parallel (mclapply()) to multictore parallelize application
# of scoreRankingGO() from GOxplorerR as it is very slow.

library(GOxploreR) # Developed with version 1.2.1 (and using BioConductor 3.13)
library(igraph)    # Developed with version 1.2.6
#Actually, don't use parallel as then GOxplorerR seems to fail and/or
# return unreliable/unreproducible results (different between runs)
#library(parallel)

cat('mc.cores =', getOption("mc.cores"), '\n')
sessionInfo()

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

  num_bin_attr = 0  
  num_cont_attr = 0
  num_cat_attr = 1
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
  cat("id cellularComponent\n", file=f)
  for (i in 1:vcount(g)) {
    cat(i, file=f)
    for (j in 1:num_cat_attr) {
      cat (" ", file=f)
      # output cat attr j value for node i
      if (j == 1) {
        cat(V(g)$cellularComponentCat[i], file=f)
      } 
      else {
        stop(paste("unknown attribute j = ", j))
      }
    }
    cat("\n", file=f)
  }
  close(f)
}


args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 0) {
  cat("Usage: getHippiePPIhighConfidenceEdgelistWithPantherAttributes.R\n")
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


## Read the PANTHER human protein classification data
panther <- read.csv("/home/stivala/PANTHER/PTHR16.0_human", sep="\t", header=FALSE, comment.char="", stringsAsFactors=FALSE)
names(panther) <- c("GeneID", "UniprotID", "FamilyID","SubFamilyID", "FamilyName","SubfamilyName","MolecularFunction","BiologicalProcess","CellularComponents","ProteinClass","Pathway")

## Read the UniProt mapping table translating entry names to accession codes
uniprot_mapping <- read.table('/home/stivala/HIPPIE/uniprot_mapping.tab', header=TRUE, stringsAsFactors=FALSE)
names(uniprot_mapping) <- c("EntryName", "UniprotID")

## join the UniProt entry names as used as node names with the UniProt mapping table
## to get the correpsponding UniProt accession (canonical) identifiers.
nodedf <- data.frame(EntryName=V(g)$name)
### Handles the cases with multiple comma-delimited entry names by just using the first
### one, since these are synonymous anyway.
##nodedf$FirstEntryName<-sapply(nodedf$EntryName, function(s) (strsplit(s, ",")[[1]][1]))
##nodedf<-(merge(nodedf, uniprot_mapping, by.x="FirstEntryName", by.y="EntryName"))
## Actually, just use the possibly comma-delimited multiple names, as these were used in generating
## the Uniprot mapping originally
nodedf<-(merge(nodedf, uniprot_mapping, by.x="EntryName", by.y="EntryName"))



##panther <- panther[sample.int(nrow(panther), 99, replace=FALSE),] # XXX small sample for testing


## Better method: Get the cellular component GO term with the highest score 
## using GOxploreR function scoreRankingGO() (Manjang et al., 2020)
## For some reason, however, this is incredibly slow (several seconds per call to scoreRankingGO()!) 
## so this version uses apply rather than loops to make it faster and/or easier to parallelize
#(Actually, don't use parallel as then GOxplorerR seems to fail and/or
# return unreliable/unreproducible results (different between runs))
# From PANTHER README http://data.pantherdb.org/ftp/sequence_classifications/current_release/README :
# Example Molecular function (the same format applies to biological process, cellular component and protein class)
# transferase activity#GO:0016740;enzyme regulator activity#GO:0030234;protein binding#GO:0005515
ccgolist <- sapply(strsplit(panther[,"CellularComponents"], ";"), FUN = function(s) gsub(".*(GO:\\d+)", "\\1", s))
#Actually, don't use parallel as then GOxplorerR seems to fail and/or
# return unreliable/unreproducible results (different between runs)
#cat("applying scoreRankingGO() in parallel with ", getOption("mc.cores"), " cores to" , length(ccgolist), " vectors of GO terms...")
# parallel version: replaces sapply(...) with simplify2array(mclapply(...))
##system.time( cellularComponent <- simplify2array(mclapply(ccgolist, function(ccgo) ifelse(length(ccgo) > 0, tryCatch({scoreranking <- scoreRankingGO(goterm = ccgo, domain = "CC", plot = FALSE); scoreranking$GO_terms_ranking[length(scoreranking$GO_terms_ranking)]}, error=function(cond){return(NA)}), NA))) )
cat("applying scoreRankingGO() to" , length(ccgolist), " vectors of GO terms...")
system.time( cellularComponent <- simplify2array(lapply(ccgolist, function(ccgo) ifelse(length(ccgo) > 0, tryCatch({scoreranking <- scoreRankingGO(goterm = ccgo, domain = "CC", plot = FALSE); scoreranking$GO_terms_ranking[length(scoreranking$GO_terms_ranking)]}, error=function(cond){return(NA)}), NA))) )

cat("There are ", length(which(is.na(cellularComponent))), "NA values for cellularComponent out of ", length(cellularComponent), " rows in Panther data\n")

## Merge the highest ranked cellular compoinent data into the data frame with node attributes
panther$bestCellularComponent <- cellularComponent
nodedf <- merge(nodedf, panther, by.x="UniprotID", by.y ="UniprotID", all.x=TRUE)

## Write the PPI node (protein) information annotated with Panther data and best ranked cellular component
## to CSV file for future reference. Note this is NOT in the same order as the protein nodes in the igraph
## object, must be joined by UniProt entry name
write.csv(nodedf, "ppi_nodes_panther_annotated.csv", row.names = FALSE)


## Now annotate the PPI graph nodes with the best ranked cellular component
notfound <- 0
multiple_notset <- 0
V(g)$cellularComponent <- NA
for (v in V(g)) {
  if (length(which(nodedf$EntryName == V(g)[v]$name)) == 1) {
    bcc <-  nodedf[which(nodedf$EntryName == V(g)[v]$name), "bestCellularComponent"]
    if (!is.na(bcc)) {
      cat('setting bcc ', bcc, 'for name ', V(g)[v]$name, '\n')#XXX
      #g <- set.vertex.attribute(g, "cellularComponent", v, bcc)
      V(g)[v]$cellularComponent <- bcc
      stopifnot(V(g)[v]$cellularComponent == bcc) # having problems with set.vertex.attribute apparently not working
      # (problem is actually not here, but below when trying to use factor():
      # it seems you cannot assign a factor value to a node attribute, have to
      # force it explicitly to be numeric instead).But here is no erroor or
      # warning, just end up with all values being NA if you try
    }
  } else if (length(which(nodedf$EntryName == V(g)[v]$name)) > 1) {
    cat("(multiple matches ", V(g)[v]$name, length(which(nodedf$EntryName == V(g)[v]$name)) ,  ")\n")
      if (length(which(nodedf$EntryName == V(g)[v]$name && !is.na(nodedf$bestCellularComponent)) ==  1)) {
        bcc <-  nodedf[which(nodedf$EntryName == V(g)[v]$name && !is.na(nodedf$bestCellularComponent)), "bestCellularComponent"]
        if (!is.na(bcc)) {
          cat('  setting bcc ', bcc, 'for name ', V(g)[v]$name, '\n')#XXX
          #g <- set.vertex.attribute(g, "cellularComponent", v, bcc)
          V(g)[v]$cellularComponent <- bcc
          stopifnot(V(g)[v]$cellularComponent == bcc) # having problems with set.vertex.attribute apparently not working
        }
    } else {
      multiple_notset <- multiple_notset + 1
    }
  } else {
    notfound <- notfound + 1
  }
}

cat("There were ", notfound, " entry names not matched to UniProt/Panther of a total ", vcount(g), " entry names in network\n")
cat("There were ", multiple_notset, " entry names with multiple matches to Uniprot/Panther but with all NA or multiple not NA cellular component so not set, of total ", vcount(g), " entry names in network\n")
cat("There are are total of ", length(which(is.na(V(g)$cellularComponent))), " NA values for cellularComponent of a total ", vcount(g), " nodes\n")

summary(g)
#print(V(g)[which(!is.na(V(g)$cellularComponent))])  #XXX
#print(V(g)[which(!is.na(V(g)$cellularComponent))]$cellularComponent)  #XXX

## Write file mapping sequential node number in igraph object to entry name for future reference
nodeiddf <- data.frame(nodeid = seq.int(vcount(g)), EntryName = V(g)$name)
write.table(nodeiddf, 'nodeid_entryname.txt', col.names=TRUE, row.names=FALSE, quote = FALSE)


# Convert cellular component to integer for categorical attribute
# Note have to explicitly make it numeric from the factor levels; cannot
# use factors in igraph node attributes it would seem
tempdf <- data.frame(factor_cellularComponent = factor(V(g)$cellularComponent))
print(levels(tempdf$factor_cellularComponent))
# This does NOT work, because of NAs:
#tempdf$cellularComponentCat <- as.numeric(levels(tempdf$factor_cellularComponent))[tempdf$factor_cellularComponent]
# So use this supposedly "non-canonical" way instead, which seems to work
# (why is R always so difficult?? -I have wasted hours on this):
tempdf$cellularComponentCat <- as.numeric(tempdf$factor_cellularComponent)

# now finally try putting it back on the igraph node attributes:
V(g)$cellularComponentCat <- tempdf$cellularComponentCat
##summary(V(g)$cellularComponentCat)

##print(V(g)[which(!is.na(V(g)$cellularComponentCat))]$cellularComponentCat)  #XXX

cat(vcount(g), "hippie_ppi_high_zones.txt", "hippie_ppi_high_edgelist.txt", "hippie_ppi_high_actors.txt", file="sampledesc.txt", sep=" ")
cat("\n", file="sampledesc.txt", sep="", append=TRUE)
write_zone_file("hippie_ppi_high_zones.txt", rep.int(0, vcount(g)))
write.graph(g, "hippie_ppi_high_edgelist.txt", format="pajek")
write_subactors_file_with_attr("hippie_ppi_high_actors.txt", g)


