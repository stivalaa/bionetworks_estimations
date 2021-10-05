#!/bin/bash

#SBATCH --job-name="yeast_tf_loops_lambda_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-loops_lambda-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-loops_lambda-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected_loops

module load openmpi

time mpirun ${ROOT}/src/EstimNetDirected_mpi config_yeast_transcription_loops_lambda.txt

module load r #most do this AFTER mpirun on new cluster otherwise MPI programs do not work

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_loops_lambda dzA_yeast_transcription_loops_lambda | tee estimation_yeast_transcription_loops_lambda.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_loops_lambda dzA_yeast_transcription_loops_lambda

echo -n "ended at: "; date

