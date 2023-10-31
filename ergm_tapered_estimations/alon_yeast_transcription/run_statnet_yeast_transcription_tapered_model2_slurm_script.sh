#!/bin/bash

#SBATCH --job-name="statnet_yeast_transcription_tapered_model2"
#SBATCH --ntasks=1
#SBATCH --time=0-11:00:00
#SBATCH --mem-per-cpu=8GB
#SBATCH --partition=slim
#SBATCH --output=statnet-yeast_transcription_tapered_model2-%j.out
#SBATCH --error=statnet-yeast_transcription_tapered_model2-%j.err

echo -n "started at: "; date
uname -a
module  load r
time Rscript statnet_yeast_transcription_tapered_model2.R
echo -n "ended at: "; date

