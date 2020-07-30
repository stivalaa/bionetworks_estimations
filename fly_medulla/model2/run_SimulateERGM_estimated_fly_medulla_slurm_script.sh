#!/bin/bash

#SBATCH --job-name="SimualateERGM_fly_medulla"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load R

rm simulation_estimated_fly_medulla_*.net

time ${ROOT}/src/SimulateERGM  config_sim_fly_medulla.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_sim_estimated_fly_medulla.txt  

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  fly_medulla_arclist.txt simulation_estimated_fly_medulla


echo -n "ended at: "; date

