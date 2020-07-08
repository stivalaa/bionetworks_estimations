#!/bin/bash

#SBATCH --job-name="ecoli1_cat_EstimNetDirected_mpi"
#SBATCH --ntasks=20
#SBATCH --time=0-1:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_self_catattr.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_self_catattr dzA_ecoli1_self_catattr | tee estimation_ecoli1_self_catattr.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_self_catattr dzA_ecoli1_self_catattr

echo -n "ended at: "; date

