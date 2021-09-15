#!/bin/bash

#SBATCH --job-name="hippie_high_SMNet_mpi"
#SBATCH --ntasks=20
#SBATCH --time=0-04:00:00

module purge
module load openmpi

SETTINGS_FILE=setting.txt
SESSION_NAME=`cat $SETTINGS_FILE | awk 'NR == 2'`
SESSION_DIR=`cat $SETTINGS_FILE | awk 'NR == 5'`
#ESTIMATION_RESULTS_FILE=$SESSION_DIR/estimation_${SESSION_NAME}.txt
ESTIMATION_RESULTS_FILES="${SESSION_DIR}/PD* ${SESSION_DIR}/RD* ${SESSION_DIR}/Res*"

echo -n "started at: "; date

cp -p ${HOME}/pasc-snowball/SMNet/SMNet_mpi .

for i in $ESTIMATION_RESULTS_FILES
do
	if [ -f $i ]; then
	  mv $i `dirname $i`/OLD_`basename $i`
	fi
done

echo "session name : $SESSION_NAME"
echo "session dir  : $SESSION_DIR"
echo "settings file: $SETTINGS_FILE"
echo "================================================================================"
cat $SETTINGS_FILE
echo "================================================================================"
echo

time mpirun  ./SMNet_mpi $SETTINGS_FILE

echo
echo estimation result files: $ESTIMATION_RESULTS_FILES
echo "================================================================================"
for i in $ESTIMATION_RESULTS_FILES
do
echo result file $i
echo "================================================================================"
cat $i
echo "================================================================================"
done

module load r

time Rscript ../../../scripts/plotSMNetParameters.R
time Rscript ../../../scripts/plotSMNetStats.R
time Rscript $HOME/Snowball/USI/scripts/plotSMNetDegreeDistribution.R
time Rscript $HOME/Snowball/USI/scripts/computeSMNetCovariance.R |tee estimation.out
times
echo -n "ended at: "; date

