#!/bin/bash

#SBATCH --job-name="ecoli_cat_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-2:00:00
#SBATCH --mem-per-cpu=2GB
#SBATCH --partition=slim
#SBATCH --output=EstimNetDirected-ecoli-selfcatsimple-%j.out
#SBATCH --error=EstimNetDirected-ecoli-selfcatsimple-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_ecoli_self_catattr_simple.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_ecoli_self_catattr_simple dzA_ecoli_self_catattr_simple | tee estimation_ecoli_self_catattr_simple.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_ecoli_self_catattr_simple dzA_ecoli_self_catattr_simple

echo -n "ended at: "; date

