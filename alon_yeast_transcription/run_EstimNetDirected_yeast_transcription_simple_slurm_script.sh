#!/bin/bash

#SBATCH --job-name="yeast_tf_simple_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-simple-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-simple-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_yeast_transcription_simple.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_simple dzA_yeast_transcription_simple | tee estimation_yeast_transcription_simple.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_simple dzA_yeast_transcription_simple

echo -n "ended at: "; date

