#!/bin/bash

#SBATCH --job-name="SimualateERGM_ecoli1_self_binattr_a2p_noatc"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load R

rm simulation_estimated_ecoli1_self_binattr_a2p_noatc_*.net

time ${ROOT}/src/SimulateERGM  config_sim_ecoli1_self_binattr_a2p_noatc.txt

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_sim_estimated_ecoli1_self_binattr_a2p_noatc.txt  

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  ecoli1_arclist.txt simulation_estimated_ecoli1_self_binattr_a2p_noatc


echo -n "ended at: "; date

