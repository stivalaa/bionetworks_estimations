#!/bin/bash -l
#
#SBATCH --job-name="yeast_ppi_fit_power_law"
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

 
echo -n "Started at: "; date

rm yeast_ppi_powerlaw.eps

time Rscript plotYeastPPIpowerLaw.R | tee yeast_ppi_powerlaw.out

times
echo -n "Finshed at: "; date
