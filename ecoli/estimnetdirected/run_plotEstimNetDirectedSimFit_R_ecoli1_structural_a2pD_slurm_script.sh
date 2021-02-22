#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=1GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit_struct_a2pD-%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit_struct_a2pD-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load r

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R ecoli1_arclist.txt sim_ecoli1_structural_a2pD

echo -n "ended at: "; date

