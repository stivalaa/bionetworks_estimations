#!/bin/bash -l
#
#SBATCH --job-name="bionetworks_make_smallworld"
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20

module load r

time make -f Makefile.smallworldtables
