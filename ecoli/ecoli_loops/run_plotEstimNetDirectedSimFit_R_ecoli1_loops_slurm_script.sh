#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit-loops"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=1GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-loops-%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-loops-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load r

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R ecoli1_arclist_loops.txt sim_ecoli1_loops

echo -n "ended at: "; date

