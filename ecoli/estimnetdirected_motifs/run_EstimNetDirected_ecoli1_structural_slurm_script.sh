#!/bin/bash

#SBATCH --job-name="ecoli1_struct_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-0:90:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli1-struct-%j.out
#SBATCH --error=EstimNetDirected-ecoli1-struct-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_ecoli1_structural.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli1_structural dzA_ecoli1_structural | tee estimation_ecoli1_structural.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli1_structural dzA_ecoli1_structural

echo -n "ended at: "; date

