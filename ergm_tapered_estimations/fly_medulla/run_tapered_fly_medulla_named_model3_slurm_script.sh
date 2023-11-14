#!/bin/bash

#SBATCH --job-name="tapered_fly_medulla_named_model3"
#SBATCH --ntasks=1
#SBATCH --time=0-01:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --partition=slim
#SBATCH --output=tapered_fly_medulla_named_model3-%j.out
#SBATCH --error=tapered_fly_medulla_named_model3-%j.err

echo -n "started at: "; date
uname -a

module load r

time Rscript taperedEstimateFlyMedullaNamedModel3.R

echo -n "ended at: "; date

