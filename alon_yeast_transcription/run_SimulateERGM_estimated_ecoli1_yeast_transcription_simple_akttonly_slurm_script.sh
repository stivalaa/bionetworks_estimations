#!/bin/bash

#SBATCH --job-name="SimualateERGM_yeast_transcription_simple_akttonly"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulatedERGM-yeast-tf-simple_akttonly-%j.out
#SBATCH --error=SimulatedERGM-yeast-tf-simple_akttonly-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5


rm simulation_estimated_yeast_transcription_simple_akttonly_*.net

time ${ROOT}/src/SimulateERGM  config_sim_yeast_transcription_simple_akttonly.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_sim_estimated_yeast_transcription_simple_akttonly.txt  

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  yeast_transcription_arclist.txt simulation_estimated_yeast_transcription_simple_akttonly


echo -n "ended at: "; date

