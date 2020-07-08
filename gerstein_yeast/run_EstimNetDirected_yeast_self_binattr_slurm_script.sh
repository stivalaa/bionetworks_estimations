#!/bin/bash

#SBATCH --job-name="yeast_bin_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-12:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-yeast-selfbin-%j.out
#SBATCH --error=EstimNetDirected-yeast-selfbin-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_yeast_self_binattr.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_self_binattr dzA_yeast_self_binattr | tee estimation_yeast_self_binattr.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_self_binattr dzA_yeast_self_binattr

echo -n "ended at: "; date

