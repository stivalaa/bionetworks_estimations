#!/bin/bash -l
#
#SBATCH --job-name="drosophila_fit_power_law"
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6

 
echo -n "Started at: "; date

rm drosophilaMedulla_powerlaw.eps

time Rscript plotDrosophilaMedullaPowerLaw.R | tee drosophila_medulla_powerlaw.out

times
echo -n "Finshed at: "; date
