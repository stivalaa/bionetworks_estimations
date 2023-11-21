#!/bin/bash -l
#
#SBATCH --job-name="kaiser_celegans277_fit_power_law"
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6

 
echo -n "Started at: "; date


time Rscript plotKaiserCelegans277PowerLaw.R| tee kaiser_celegans277_powerlaw.out

times
echo -n "Finshed at: "; date
