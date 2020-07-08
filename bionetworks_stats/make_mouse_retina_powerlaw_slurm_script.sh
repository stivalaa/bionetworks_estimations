#!/bin/bash -l
#
#SBATCH --job-name="mouse_retina_fit_power_law"
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

rm mouse_retina_powerlaw.eps

time Rscript plotMouseRetinaPowerLaw.R | tee mouse_retina_powerlaw.out

times
echo -n "Finshed at: "; date
