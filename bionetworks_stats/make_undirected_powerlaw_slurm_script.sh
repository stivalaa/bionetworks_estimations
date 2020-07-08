#!/bin/bash -l
#
#SBATCH --job-name="undirected_fit_power_law"
#SBATCH --time=3:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

rm undirected_bionetworks_powerlaw.eps

time Rscript plotUndirectedBionetworksPowerLaw.R | tee undirected_bionetworks_powerlaw.out

times
echo -n "Finshed at: "; date
