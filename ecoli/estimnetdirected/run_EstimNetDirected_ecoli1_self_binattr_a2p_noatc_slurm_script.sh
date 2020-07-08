#!/bin/bash

#SBATCH --job-name="ecoli1_bin_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-self-binattr-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-self-binattr-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_self_binattr_a2p_noatc.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_self_binattr_a2p_noatc dzA_ecoli1_self_binattr_a2p_noatc | tee estimation_ecoli1_self_binattr_a2p_noatc.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_self_binattr_a2p_noatc dzA_ecoli1_self_binattr_a2p_noatc

echo -n "ended at: "; date

