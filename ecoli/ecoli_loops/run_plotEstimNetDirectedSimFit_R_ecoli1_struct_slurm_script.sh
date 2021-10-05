#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit-struct"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=1GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-struct-%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-struct-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load r

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R ecoli1_arclist_loops.txt sim_ecoli1_struct

echo -n "ended at: "; date

