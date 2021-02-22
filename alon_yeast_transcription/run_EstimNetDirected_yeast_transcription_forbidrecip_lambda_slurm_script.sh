#!/bin/bash

#SBATCH --job-name="yeast_tf_forbidrecip_lambda_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-forbidrecip_lambda-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-forbidrecip_lambda-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time mpirun ./EstimNetDirected_mpi config_yeast_transcription_forbidrecip_lambda.txt

module load r #most do this AFTER mpirun on new cluster otherwise MPI programs do not work

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_forbidrecip_lambda dzA_yeast_transcription_forbidrecip_lambda | tee estimation_yeast_transcription_forbidrecip_lambda.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_forbidrecip_lambda dzA_yeast_transcription_forbidrecip_lambda

echo -n "ended at: "; date

