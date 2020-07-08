#!/bin/bash

#SBATCH --job-name="ecoli_struct_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli-struct-%j.out
#SBATCH --error=EstimNetDirected-ecoli-struct-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_ecoli_struct.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli_struct dzA_ecoli_struct | tee estimation_ecoli_struct.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli_struct dzA_ecoli_struct

echo -n "ended at: "; date

