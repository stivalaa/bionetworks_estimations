#!/bin/bash

#SBATCH --job-name="ecoli1_cat_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-1:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-cat_noatc-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-cat_noatc-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_self_catattr_a2p_noatc.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_self_catattr_a2p_noatc dzA_ecoli1_self_catattr_a2p_noatc | tee estimation_ecoli1_self_catattr_a2p_noatc.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_self_catattr_a2p_noatc dzA_ecoli1_self_catattr_a2p_noatc

echo -n "ended at: "; date

