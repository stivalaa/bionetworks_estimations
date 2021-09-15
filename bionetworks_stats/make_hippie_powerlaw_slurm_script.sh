#!/bin/bash -l
#
#SBATCH --job-name="hippie_fit_power_law"
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

module load r

rm hippie_powerlaw.eps

time Rscript plotHIPPIEPowerLaw.R | tee hippie_powerlaw.out

times
echo -n "Finshed at: "; date
