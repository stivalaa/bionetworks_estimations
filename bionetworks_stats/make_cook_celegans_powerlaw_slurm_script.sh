#!/bin/bash -l
#
#SBATCH --job-name="cook_celegans_fit_power_law"
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6

 
echo -n "Started at: "; date

rm GMaleChem_powerlaw.eps

time Rscript plotGMaleChemPowerLaw.R | tee cook_celegans_powerlaw.out

times
echo -n "Finshed at: "; date
