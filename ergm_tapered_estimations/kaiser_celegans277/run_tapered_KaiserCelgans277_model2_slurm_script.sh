#!/bin/bash

#SBATCH --job-name="tapered_KaiserCelegans277_model2"
#SBATCH --ntasks=1
#SBATCH --time=0-48:00:00
#SBATCH --mem-per-cpu=4GB
#SBATCH --output=tapered-KaiserCelegans277_model2-%j.out
#SBATCH --error=tapered-KaiserCelegans277_model2-%j.err

echo -n "started at: "; date
uname -a
command -v module >/dev/null 2>&1 && module load gcc/11.3.0 # needed by r/4.2.1
command -v module >/dev/null 2>&1 && module load openmpi/4.1.4 # needed by r/4.2.1
command -v module >/dev/null 2>&1 && module load r/4.2.1
time Rscript taperedEstimateKaiserCelegans277Model2.R
echo -n "ended at: "; date

