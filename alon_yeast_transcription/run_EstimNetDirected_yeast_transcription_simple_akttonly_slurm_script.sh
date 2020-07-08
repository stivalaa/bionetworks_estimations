#!/bin/bash

#SBATCH --job-name="yeast_tf_simple_akttonly_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-03:00:00
#SBATCH --output=EstimNetDirected-yeast-tf-simple_akttonly-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-simple_akttonly-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
module load R

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time srun ./EstimNetDirected_mpi config_yeast_transcription_simple_akttonly.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_simple_akttonly dzA_yeast_transcription_simple_akttonly | tee estimation_yeast_transcription_simple_akttonly.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_simple_akttonly dzA_yeast_transcription_simple_akttonly

echo -n "ended at: "; date

