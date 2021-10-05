#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit_loops"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-loops_lambda%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-loops_lambda%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load r

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R yeast_arclist_loops.txt sim_yeast_transcription_loops_lambda

echo -n "ended at: "; date

