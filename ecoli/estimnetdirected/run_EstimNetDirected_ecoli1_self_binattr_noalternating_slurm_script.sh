#!/bin/bash

#SBATCH --job-name="ecoli1_bin_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-self-binattr-noalternating-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-self-binattr-noalternating-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_self_binattr_noalternating.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_self_binattr_noalternating dzA_ecoli1_self_binattr_noalternating | tee estimation_ecoli1_self_binattr_noalternating.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_self_binattr_noalternating dzA_ecoli1_self_binattr_noalternating

echo -n "ended at: "; date

