#!/bin/bash

#SBATCH --job-name="ecoli2_m5_SMNet_mpi"
#SBATCH --ntasks=20
#SBATCH --time=0-0:30:00
##SBATCH -p physical

SETTINGS_FILE=setting.txt
SESSION_NAME=`cat $SETTINGS_FILE | awk 'NR == 2'`
SESSION_DIR=`cat $SETTINGS_FILE | awk 'NR == 5'`
#ESTIMATION_RESULTS_FILE=$SESSION_DIR/estimation_${SESSION_NAME}.txt
ESTIMATION_RESULTS_FILES="${SESSION_DIR}/PD* ${SESSION_DIR}/RD* ${SESSION_DIR}/Res*"


echo -n "started at: "; date

SMNET_DIR=${HOME}/pasc-snowball/SMNet
cp -p ${SMNET_DIR}/SMNet_mpi .

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

time Rscript ../../scripts/plotSMNetParameters.R
time Rscript ../../scripts/plotSMNetStats.R
time Rscript ../../scripts/plotSMNetDegreeDistribution.R
time Rscript ../../scripts/computeSMNetCovariance.R |tee estimation.out


#echo "================================================================================"
#echo SMNet version information:
#echo ${SMNET_DIR}
#(cd ${SMNET_DIR} 
#  for i in *.[hc]
#  do
#    echo i $i " " ; svn info $i | grep Revision
#  done
#)
#echo "================================================================================"

times
echo -n "ended at: "; date

