#!/bin/bash -l
#
#SBATCH --job-name="drosophila_distance_plots"
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

 
echo -n "Started at: "; date

time Rscript plotDrosophilaMedullaDistanceDistributions.R | tee drosophila_medulla_distanceplots.out

times
echo -n "Finshed at: "; date
