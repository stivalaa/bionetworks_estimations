#!/bin/bash

#SBATCH --job-name="plotEstimNetDirectedSimFit"
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=PlotEstimNetDirectedSimFit-noa2p_lambda%j.out
#SBATCH --error=PlotEstimNetDirectedSimFit-noa2p_lambda%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load r

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R yeast_transcription_arclist.txt sim_yeast_transcription_noa2p_lambda

echo -n "ended at: "; date

