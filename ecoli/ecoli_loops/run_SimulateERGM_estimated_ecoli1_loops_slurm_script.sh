#!/bin/bash

#SBATCH --job-name="SimulateERGM_ecoli1_loops"
#SBATCH --ntasks=1
#SBATCH --time=0-0:30:00
#SBATCH --output=SimulateERGM-gof_ecoli_loops-%j.out
#SBATCH --error=SimulateERGM-gof_ecoli_loops-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

rm sim_gof_ecoli1_loops_*.net

time ${ROOT}/src/SimulateERGM  config_gof_ecoli1_loops.txt

module load r

time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_ecoli1_loops.txt  obs_stats_ecoli1_loops_0.txt

time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R -s  ecoli1_arclist_loops.txt sim_gof_ecoli1_loops


echo -n "ended at: "; date

