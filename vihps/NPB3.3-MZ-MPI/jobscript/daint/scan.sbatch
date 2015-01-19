#!/bin/bash
# submit from ./bin.scorep directory with "sbatch scan.sbatch"
#SBATCH --job-name="scan_mzmpibt"
#SBATCH --nodes=4
#SBATCH --ntasks=8
#SBATCH --time=00:10:00
#SBATCH --res=course

# benchmark configuration
export OMP_NUM_THREADS=4
NPROCS=8
CLASS=C
EXE=./bt-mz_$CLASS.$NPROCS

#module load scalasca/2.1

# Scalasca configuration
export NEXUS="scalasca -analyze -f ../config/scorep.filt"

# Score-P configuration
#export SCOREP_TOTAL_MEMORY=53M

set -x
$NEXUS  aprun -n $NPROCS -d $OMP_NUM_THREADS  $EXE

