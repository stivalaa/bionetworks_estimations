#!/bin/bash

#SBATCH --job-name="tapered_fly_medulla_named_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-04:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --partition=slim
#SBATCH --output=tapered_fly_medulla_named_model1-%j.out
#SBATCH --error=tapered_fly_medulla_named_model1-%j.err

echo -n "started at: "; date
uname -a

module load r

time Rscript taperedEstimateFlyMedullaNamedModel1.R

echo -n "ended at: "; date

