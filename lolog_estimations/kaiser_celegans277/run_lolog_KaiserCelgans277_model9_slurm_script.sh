#!/bin/bash

#SBATCH --job-name="lolog_KaiserCelegans277_model9"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --output=lolog-KaiserCelegans277_model9-%j.out
#SBATCH --error=lolog-KaiserCelegans277_model9-%j.err

echo -n "started at: "; date
uname -a
command -v module >/dev/null 2>&1 && module load gcc/11.3.0 # needed by r/4.2.1
command -v module >/dev/null 2>&1 && module load openmpi/4.1.4 # needed by r/4.2.1
command -v module >/dev/null 2>&1 && module load r/4.2.1
time Rscript lologEstimateKaiserCelegans277Model9.R
echo -n "ended at: "; date

