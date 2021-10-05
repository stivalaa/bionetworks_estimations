#!/bin/bash

#SBATCH --job-name="statnet_ecoli_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=statnet-ecoli_model1-%j.out
#SBATCH --error=statnet-ecoli_model1-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript statnet_ecoli_model1.R
echo -n "ended at: "; date

