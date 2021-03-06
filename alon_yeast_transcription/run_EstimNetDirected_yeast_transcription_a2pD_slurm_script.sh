#!/bin/bash

#SBATCH --job-name="yeast_tf_a2pD_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-a2pD-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-a2pD-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time mpirun ./EstimNetDirected_mpi config_yeast_transcription_a2pD.txt

module load r

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_a2pD dzA_yeast_transcription_a2pD | tee estimation_yeast_transcription_a2pD.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_a2pD dzA_yeast_transcription_a2pD

echo -n "ended at: "; date

