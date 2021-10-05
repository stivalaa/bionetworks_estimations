#!/bin/bash

#SBATCH --job-name="statnet_ecoli_stepping_model3"
#SBATCH --ntasks=1
#SBATCH --time=0-8:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=statnet-ecoli_stepping_model3-%j.out
#SBATCH --error=statnet-ecoli_stepping_model3-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript statnet_ecoli_stepping_model3.R
echo -n "ended at: "; date

