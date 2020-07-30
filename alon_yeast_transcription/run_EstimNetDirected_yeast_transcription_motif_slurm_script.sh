#!/bin/bash

#SBATCH --job-name="yeast_tf_motif_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-00:30:00
#SBATCH --output=EstimNetDirected-yeast-tf-motif-%j.out
#SBATCH --error=EstimNetDirected-yeast-tf-motif-%j.err


echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

module load openmpi
echo "*** Remember must 'module load R/3.2.5' to get Microsoft R Open 3.2.5 otherwise nothing in R works! (doing that now) ***"
echo
module load R/3.2.5

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi

time mpirun ./EstimNetDirected_mpi config_yeast_transcription_motif.txt

time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_motif dzA_yeast_transcription_motif | tee estimation_yeast_transcription_motif.out
time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_motif dzA_yeast_transcription_motif

echo -n "ended at: "; date

