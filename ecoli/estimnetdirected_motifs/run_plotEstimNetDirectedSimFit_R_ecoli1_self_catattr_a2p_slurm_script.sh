#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=1GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load R

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R ecoli1_arclist.txt sim_ecoli1_self_catattr_a2p

echo -n "ended at: "; date

