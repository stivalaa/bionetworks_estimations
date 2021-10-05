#!/bin/bash

#SBATCH --job-name="SimulateERGM_ecoli1_struct"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulateERGM-gof_ecoli_struct-%j.out
#SBATCH --error=SimulateERGM-gof_ecoli_struct-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

rm sim_gof_ecoli1_struct*.net

time ${ROOT}/src/SimulateERGM  config_gof_ecoli1_struct.txt

module load r

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_ecoli1_struct.txt  obs_stats_ecoli1_struct_0.txt

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R -s  ecoli1_arclist_loops.txt sim_gof_ecoli1_struct


echo -n "ended at: "; date

