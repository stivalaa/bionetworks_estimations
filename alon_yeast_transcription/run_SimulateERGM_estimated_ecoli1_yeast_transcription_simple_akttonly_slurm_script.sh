#!/bin/bash

#SBATCH --job-name="SimualateERGM_yeast_transcription_simple_akttonly"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load R

rm simulation_estimated_yeast_transcription_simple_akttonly_*.net

time ${ROOT}/src/SimulateERGM  config_sim_yeast_transcription_simple_akttonly.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_sim_estimated_yeast_transcription_simple_akttonly.txt  

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  yeast_transcription_arclist.txt simulation_estimated_yeast_transcription_simple_akttonly


echo -n "ended at: "; date

