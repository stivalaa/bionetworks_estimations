#!/bin/bash

#SBATCH --job-name="lolog_yeast_ppi_model2"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=120GB
#SBATCH --partition=fat
#SBATCH --output=lolog_yeast_ppi_model2-%j.out
#SBATCH --error=lolog_yeast_ppi_model2-%j.err

echo -n "started at: "; date

module load r

time Rscript lologEstimateYeastPPIModel2.R

echo -n "ended at: "; date

