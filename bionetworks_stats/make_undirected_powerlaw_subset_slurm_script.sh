#!/bin/bash -l
#
#SBATCH --job-name="undirected_fit_power_law_subset"
#SBATCH --time=3:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

module load r

rm undirected_bionetworks_powerlaw_subset.eps

time Rscript plotUndirectedBionetworksPowerLawSubset.R | tee undirected_bionetworks_powerlaw_subset.out

times
echo -n "Finshed at: "; date
