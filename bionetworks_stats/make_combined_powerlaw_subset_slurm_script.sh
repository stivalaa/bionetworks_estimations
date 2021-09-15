#!/bin/bash -l
#
#SBATCH --job-name="fit_power_law_subset"
#SBATCH --time=0:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

 
echo -n "Started at: "; date

module load r

rm combined_bionetworks_powerlaw_subset.eps
rm combined_bionetworks_powerlaw_subset.pdf

time Rscript plotCombinedBioNetworksPowerLawSubset.R | tee combined_bionetworks_powerlaw_subset.out

ps2pdf combined_bionetworks_powerlaw_subset.eps

times
echo -n "Finshed at: "; date
