#!/bin/bash

#SBATCH --job-name="SimualateERGM_ecoli1_structural"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected



time ${ROOT}/src/SimulateERGM  config_sim_ecoli1_structural.txt

module load r

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_sim_estimated_ecoli1_structural.txt  

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  ecoli1_arclist.txt simulation_estimated_ecoli1_structural


echo -n "ended at: "; date

