#!/bin/bash

#SBATCH --job-name="SimulateERGM_yeast_transcription_simple_noaktc_lambda"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulatedERGM-yeast-tf-simple_noaktc_lambda-%j.out
#SBATCH --error=SimulatedERGM-yeast-tf-simple_noaktc_lambda-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected


rm simulation_gof_yeast_transcription_simple_noaktc_lambda_*.net

time ${ROOT}/src/SimulateERGM  config_gof_simulation_yeast_transcription_simple_noaktc_lambda.txt

module load r

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_simulation_yeast_transcription_simple_noaktc_lambda.txt  obs_stats_yeast_transcription_simple_noaktc_lambda_0.txt

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  -s yeast_transcription_arclist.txt simulation_gof_yeast_transcription_simple_noaktc_lambda


echo -n "ended at: "; date

