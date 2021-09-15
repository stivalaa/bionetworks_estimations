#!/bin/bash

#SBATCH --job-name="SimulateERGM-gridsearch-yeast_transcription_nosinksource_lambda"
#SBATCH --ntasks=1
#SBATCH --mem=2GB
#SBATCH --time=0-2:00:00
#SBATCH --output=SimulatedERGM-gridsearch-yeast-tf-nosinksource_lambda-%j.out
#SBATCH --error=SimulatedERGM-gridsearch-yeast-tf-nosinksource_lambda-%j.err

echo -n "started at: "; date

ROOT=${HOME}/EstimNetDirected

# WARNING: overwites output file if it exists
OUTFILE=gridsearch_gof_stats.txt

AOUTS_LAMBDA_VALUES=`seq 1.5 0.5 5.0`
AKTT_LAMBDA_VALUES=`seq 1.5 0.5 5.0`

module load r

echo "run aouts_lambda aktt_lambda effect observed mean sd t_ratio" > ${OUTFILE}

model=1 # just an identifier for each model (unique set of lambda hyperparameers) to make grouping easier instead of having to group by lambda values when using output in R etc.
for aouts_lambda in $AOUTS_LAMBDA_VALUES
do
  for aktt_lambda in $AKTT_LAMBDA_VALUES
  do
    echo aouts_lambda = ${aouts_lambda}, aktt_lambda = ${aktt_lambda}

    ${ROOT}/scripts/estimnetdirectedEstimation2simulationConfig.sh config_yeast_transcription_nosinksource_lambdaa_AOUTS${aouts_lambda}_AKTT${aktt_lambda} estimation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.out stats_gof_simulation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.txt  simulation_gof_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda} >  config_gof_simulation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.txt
    
    time ${ROOT}/src/SimulateERGM  config_gof_simulation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.txt
    
    time Rscript ${ROOT}/scripts/plotSimulationDiagnostics.R stats_gof_simulation_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.txt  obs_stats_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}_0.txt | tee gof_sim_stats_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.out
    
    # Remove the header line "effect observed mean sd t_ratio", and the two trailing lines "null device" "1" from the R script plotting
    # and append to file with stats from all lambda hyperparameters
    cat gof_sim_stats_AOUTS${aouts_lambda}_AKTT${aktt_lambda}.out | head -n-2 | tail -n +2 | sed "s/^/${model} ${aouts_lambda} ${aktt_lambda} /" >> ${OUTFILE}
    
    time Rscript ${ROOT}/scripts/plotEstimNetDirectedSimFit.R  -s yeast_transcription_arclist.txt simulation_gof_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda}
    model=`expr ${model} + 1`
  done
done   

echo -n "ended at: "; date

