#!/bin/bash

#SBATCH --job-name="drosophila_medulla_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5


cp -p ${ROOT}/src/EstimNetDirected_mpi .

time srun ./EstimNetDirected_mpi config_fly_medulla.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_fly_medulla dzA_fly_medulla | tee estimation_fly_medulla.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_fly_medulla dzA_fly_medulla

echo -n "ended at: "; date

