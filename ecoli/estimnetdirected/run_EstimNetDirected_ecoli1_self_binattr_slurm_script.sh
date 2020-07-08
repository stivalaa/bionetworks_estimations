#!/bin/bash

#SBATCH --job-name="ecoli1_bin_EstimNetDirected_mpi"
#SBATCH --ntasks=20
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_self_binattr.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_self_binattr dzA_ecoli1_self_binattr | tee estimation_ecoli1_self_binattr.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_self_binattr dzA_ecoli1_self_binattr

echo -n "ended at: "; date

