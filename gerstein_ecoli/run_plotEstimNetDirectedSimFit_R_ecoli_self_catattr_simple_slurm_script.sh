#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-self-catattrsimple-%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-self-catattrsimple-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load R

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R ecoli_arclist.txt sim_ecoli_self_catattr_simple

echo -n "ended at: "; date

