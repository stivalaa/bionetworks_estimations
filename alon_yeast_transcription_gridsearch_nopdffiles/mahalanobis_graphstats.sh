#!/bin/sh

AOUTS_LAMBDA_VALUES=`seq 1.5 0.5 5.0`
AKTT_LAMBDA_VALUES=`seq 1.5 0.5 5.0`

echo aouts_lambda aktt_lambda Mahalanobis
for aouts_lambda in $AOUTS_LAMBDA_VALUES; do   
	for aktt_lambda in $AKTT_LAMBDA_VALUES;   do
		mdist=`Rscript ~/EstimNetDirected/scripts/statsEstimNetDirectedSimFit.R yeast_transcription_arclist.txt  simulation_gof_yeast_transcription_nosinksource_lambda_AOUTS${aouts_lambda}_AKTT${aktt_lambda} | grep '^Mahalanobis =' | awk '{print $3}'`
		echo $aouts_lambda $aktt_lambda $mdist
	done
done 
