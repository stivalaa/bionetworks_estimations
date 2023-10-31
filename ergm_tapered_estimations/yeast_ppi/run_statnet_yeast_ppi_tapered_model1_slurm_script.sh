#!/bin/bash

#SBATCH --job-name="statnet_yeast_ppi_tapered_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=statnet-yeast_ppi_tapered_model1-%j.out
#SBATCH --error=statnet-yeast_ppi_tapered_model1-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript statnet_yeast_ppi_tapered_model1.R
echo -n "ended at: "; date

