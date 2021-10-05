#!/bin/bash

#SBATCH --job-name="ecoli1_loops_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-0:20:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-loops-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-loops-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load openmpi

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time mpirun ./EstimNetDirected_mpi config_ecoli1_loops.txt

module load r

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_loops dzA_ecoli1_loops | tee estimation_ecoli1_loops.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_loops dzA_ecoli1_loops

echo -n "ended at: "; date

