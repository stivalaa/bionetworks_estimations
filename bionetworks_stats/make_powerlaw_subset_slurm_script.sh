#!/bin/bash -l
#
#SBATCH --job-name="bionetworks_fit_power_law"
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

rm directed_bionetworks_powerlaw_subset.eps

time Rscript plotDirectedBioNetworksPowerLawSubset.R | tee directed_bionetworks_powerlaw_subset.out

times
echo -n "Finshed at: "; date
