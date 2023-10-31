#!/bin/bash

#SBATCH --job-name="lolog_GMaleChem_model2"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=lolog-GMaleChem_model2-%j.out
#SBATCH --error=lolog-GMaleChem_model2-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript lolog_GMaleChem_model2.R
echo -n "ended at: "; date

