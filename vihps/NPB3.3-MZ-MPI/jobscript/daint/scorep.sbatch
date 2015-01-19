#!/bin/bash
# submit from ./bin.scorep directory with "sbatch scorep.sbatch"
#SBATCH --job-name="scorep_mzmpibt"
#SBATCH --nodes=4
#SBATCH --ntasks=8
#SBATCH --time=00:10:00
#SBATCH --res=course

# benchmark configuration
export OMP_NUM_THREADS=4
NPROCS=8
CLASS=C
EXE=./bt-mz_$CLASS.$NPROCS

#module load scorep/1.3

# Score-P measurement configuration
#export SCOREP_EXPERIMENT_DIRECTORY=scorep_sum
#export SCOREP_FILTERING_FILE=../config/scorep.filt
#export SCOREP_METRIC_PAPI=PAPI_TOT_INS,PAPI_FP_INS
#export SCOREP_METRIC_PAPI_PER_PROCESS=PAPI_L2_TCM
#export SCOREP_METRIC_RUSAGE=ru_stime
#export SCOREP_METRIC_RUSAGE_PER_PROCESS=ru_maxrss

set -x
aprun -n $NPROCS -d $OMP_NUM_THREADS  $EXE

