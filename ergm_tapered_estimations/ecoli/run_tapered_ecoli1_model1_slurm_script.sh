#!/bin/bash

#SBATCH --job-name="tapered_ecoli1_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-01:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --partition=slim
#SBATCH --output=tapered_ecoli1_model1-%j.out
#SBATCH --error=tapered_ecoli1_model1-%j.err

echo -n "started at: "; date

module load r

time Rscript taperedEstimateEcoli1Model1.R

echo -n "ended at: "; date
