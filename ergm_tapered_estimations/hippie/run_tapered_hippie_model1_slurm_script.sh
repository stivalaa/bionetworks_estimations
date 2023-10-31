#!/bin/bash

#SBATCH --job-name="tapered_hippie_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=tapered_hippie_model1-%j.out
#SBATCH --error=tapered_hippie_model1-%j.err


echo -n "started at: "; date

module load r

time Rscript taperedEstimateHIPPIEModel1.R

echo -n "ended at: "; date

