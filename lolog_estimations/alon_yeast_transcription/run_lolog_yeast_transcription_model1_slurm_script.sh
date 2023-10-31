#!/bin/bash

#SBATCH --job-name="lolog_yeast_transcription_model1"
#SBATCH --ntasks=1
#SBATCH --time=0-01:00:00
#SBATCH --mem-per-cpu=6GB
#SBATCH --partition=slim
#SBATCH --output=lolog_yeast_transcription_model1-%j.out
#SBATCH --error=lolog_yeast_transcription_model1-%j.err

echo -n "started at: "; date

module load r

time Rscript lologEstimateAlonYeastTranscriptionModel1.R

echo -n "ended at: "; date

