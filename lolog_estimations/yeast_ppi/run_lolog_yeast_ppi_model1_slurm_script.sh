#!/bin/bash

#SBATCH --job-name="lolog_yeast_ppi_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-47:00:00
#SBATCH --mem-per-cpu=120GB
#SBATCH --partition=fat
#SBATCH --output=lolog_yeast_ppi_model1-%j.out
#SBATCH --error=lolog_yeast_ppi_model1-%j.err

echo -n "started at: "; date

module load r

time Rscript lologEstimateYeastPPIModel1.R

echo -n "ended at: "; date

