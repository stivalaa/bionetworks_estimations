#!/bin/bash

#SBATCH --job-name="ecoli1_struct_a2pD_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-0:90:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-struct_a2pD-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-struct_a2pD-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time mpirun ./EstimNetDirected_mpi config_ecoli1_structural_a2pD.txt

module load r

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_structural_a2pD dzA_ecoli1_structural_a2pD | tee estimation_ecoli1_structural_a2pD.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_structural_a2pD dzA_ecoli1_structural_a2pD

echo -n "ended at: "; date

