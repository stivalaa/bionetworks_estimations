#!/bin/bash

#SBATCH --job-name="yeast_tf_simple_noaktc_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-simple_noaktc-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-simple_noaktc-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_yeast_transcription_simple_noaktc.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_simple_noaktc dzA_yeast_transcription_simple_noaktc | tee estimation_yeast_transcription_simple_noaktc.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_simple_noaktc dzA_yeast_transcription_simple_noaktc

echo -n "ended at: "; date

