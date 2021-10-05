#!/bin/bash

#SBATCH --job-name="statnet_ecoli_stepping_model4"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=statnet-ecoli_stepping_model4-%j.out
#SBATCH --error=statnet-ecoli_stepping_model4-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript statnet_ecoli_stepping_model4.R
echo -n "ended at: "; date

