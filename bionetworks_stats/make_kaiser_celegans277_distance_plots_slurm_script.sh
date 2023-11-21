#!/bin/bash -l
#
#SBATCH --job-name="drosophila_distance_plots"
#SBATCH --time=0:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

 
echo -n "Started at: "; date

time Rscript plotKaiserCelegans277DistanceDistributions.R| tee kaiser_celegans277_distanceplots.out

times
echo -n "Finshed at: "; date
