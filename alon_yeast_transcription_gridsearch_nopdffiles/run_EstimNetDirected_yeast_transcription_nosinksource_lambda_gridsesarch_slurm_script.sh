#!/bin/bash

#SBATCH --job-name="yeast_tf_gridsearch_nosinksource_lambda_EstimNetDirected_mpi"
#SBATCH --ntasks=64
#SBATCH --time=0-12:00:00
#SBATCH --output=EstimNetDirected-gridsearch-yeast-tf-nosinksource_lambda-%j.out
#SBATCH --error=EstimNetDirected-gridsearch-yeast-tf-nosinksource_lambda-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

TEMPLATE_CONFIG=template_config_yeast_transcription_nosinksource_lambda.txt
AOUTS_LAMBDA_VALUES=`seq 1.5 0.5 5.0`
AKTT_LAMBDA_VALUES=`seq 1.5 0.5 5.0`


module purge
module load openmpi

if [ ! -f EstimNetDirected_mpi -o ${ROOT}/src/EstimNetDirected_mpi -nt EstimNetDirected_mpi  ]; then
	cp -p ${ROOT}/src/EstimNetDirected_mpi .
fi


for aouts_lambda in $AOUTS_LAMBDA_VALUES
do
  for aktt_lambda in $AKTT_LAMBDA_VALUES
  do
    config_file=config_yeast_transcription_nosinksource_lambdaa_AOUTS${aouts_lambda}_AKTT${aktt_lambda}
    cat $TEMPLATE_CONFIG | sed "s/@LAMBDA_AOUTS/${aouts_lambda}/g;s/@LAMBDA_AKTT/${aktt_lambda}/g" > $config_file
    time mpirun ./EstimNetDirected_mpi $config_file
  done
done


module load r #most do this AFTER mpirun on new cluster otherwise MPI programs do not work

for aouts_lambda in $AOUTS_LAMBDA_VALUES
do
  for aktt_lambda in $AKTT_LAMBDA_VALUES
  do
    time Rscript ${ROOT}/scripts/computeEstimNetDirectedCovariance.R theta_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda} dzA_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda} | tee estimation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.out
    time Rscript ${ROOT}/scripts/plotEstimNetDirectedResults.R theta_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda} dzA_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}
  done
done



echo -n "ended at: "; date

