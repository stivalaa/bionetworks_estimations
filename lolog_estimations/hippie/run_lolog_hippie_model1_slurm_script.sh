#!/bin/bash

#SBATCH --job-name="lolog_hippie_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=120GB
#SBATCH --partition=fat
#SBATCH --output=lolog_hippie_model1-%j.out
#SBATCH --error=lolog_hippie_model1-%j.err

# Note very large memory usge, seems to steadily increase after each iteration

echo -n "started at: "; date

module load r

time Rscript lologEstimateHIPPIEModel1.R

echo -n "ended at: "; date

