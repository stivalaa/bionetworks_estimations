#!/bin/bash

#SBATCH --job-name="lolog_ecoli1_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-01:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --partition=slim
#SBATCH --output=lolog_ecoli1_model1-%j.out
#SBATCH --error=lolog_ecoli1_model1-%j.err

echo -n "started at: "; date

module load r

time Rscript lologEstimateEcoli1Model1.R

echo -n "ended at: "; date

