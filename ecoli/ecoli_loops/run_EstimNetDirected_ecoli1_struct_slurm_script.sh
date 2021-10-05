#!/bin/bash

#SBATCH --job-name="ecoli1_struct_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-0:20:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-struct-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-struct-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load openmpi

time mpirun ${ROOT}/src/EstimNetDirected_mpi config_ecoli1_struct.txt

module load r

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_struct dzA_ecoli1_struct | tee estimation_ecoli1_struct.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_struct dzA_ecoli1_struct

echo -n "ended at: "; date

