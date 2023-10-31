#!/bin/bash

#SBATCH --job-name="build_PPI_GO_network_R"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0-48:00:00
#SBATCH --partition=slim
#SBATCH --mem-per-cpu=2GB
#SBATCH --output=build_PPI_GO_network-%j.out
#SBATCH --error=build_PPI_GO_network-%j.err


echo -n "started at: "; date

module load r

time Rscript ../../../scripts/getHippiePPIhighConfidenceEdgelistWithPantherAttributes.R | tee getHippiePPIhighConfidenceEdgelistWithPantherAttributes.out

echo -n "ended at: "; date

