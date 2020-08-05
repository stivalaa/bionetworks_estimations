#!/bin/bash

#SBATCH --job-name="SimulateERGM_yeast_transcription_reciprocity"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulatedERGM-yeast-tf-reciprocity-%j.out
#SBATCH --error=SimulatedERGM-yeast-tf-reciprocity-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5

rm simulation_gof_yeast_transcription_reciprocity_*.net

time ${ROOT}/src/SimulateERGM  config_gof_simulation_yeast_transcription_reciprocity.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_simulation_yeast_transcription_reciprocity.txt 

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  yeast_transcription_arclist.txt simulation_gof_yeast_transcription_reciprocity


echo -n "ended at: "; date

