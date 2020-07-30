#!/bin/bash

#SBATCH --job-name="SimulateERGM_fly_medulla"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5

rm simulation_gof_fly_medulla_*.net

time ${ROOT}/src/SimulateERGM  config_gof_simulation_fly_medulla.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_simulation_fly_medulla.txt

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  fly_medulla_arclist.txt simulation_gof_fly_medulla


echo -n "ended at: "; date

