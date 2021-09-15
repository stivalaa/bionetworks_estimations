#!/bin/bash

#SBATCH --job-name="build_PPI_GO_network_R_parallel"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=0-48:00:00
#SBATCH --partition=slim
#SBATCH --mem-per-cpu=2GB
#SBATCH --output=build_PPI_GO_network_parallel-%j.out
#SBATCH --error=build_PPI_GO_network_parallel-%j.err


echo -n "started at: "; date

export MC_CORES=${SLURM_CPUS_ON_NODE}

echo MC_CORES = $MC_CORES

module load r

time Rscript ../../../scripts/getHippiePPIhighConfidenceEdgelistWithPantherAttributes.R | tee getHippiePPIhighConfidenceEdgelistWithPantherAttributes.out

echo -n "ended at: "; date

