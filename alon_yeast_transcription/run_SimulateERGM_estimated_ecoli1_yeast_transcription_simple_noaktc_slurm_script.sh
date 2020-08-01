#!/bin/bash

#SBATCH --job-name="SimulateERGM_yeast_transcription_simple_noaktc"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulatedERGM-yeast-tf-simple_noaktc-%j.out
#SBATCH --error=SimulatedERGM-yeast-tf-simple_noaktc-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5

rm simulation_gof_yeast_transcription_simple_noaktc_*.net

time ${ROOT}/src/SimulateERGM  config_gof_simulation_yeast_transcription_simple_noaktc.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_simulation_yeast_transcription_simple_noaktc.txt 

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  yeast_transcription_arclist.txt simulation_gof_yeast_transcription_simple_noaktc


echo -n "ended at: "; date

