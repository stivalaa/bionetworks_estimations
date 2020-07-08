#!/bin/bash

#SBATCH --job-name="yeast_structural_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-12:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-yeast-structural-%j.out
#SBATCH --error=EstimNetDirected-yeast-structural-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_yeast_structural.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_structural dzA_yeast_structural | tee estimation_yeast_structural.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_structural dzA_yeast_structural

echo -n "ended at: "; date

