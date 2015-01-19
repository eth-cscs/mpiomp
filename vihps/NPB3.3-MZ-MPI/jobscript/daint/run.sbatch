#!/bin/bash
# submit from ./bin directory with "sbatch run.sbatch"
#SBATCH --job-name="mzmpibt"

##SBATCH --nodes=4
#SBATCH --ntasks=8              # -n
#SBATCH --ntasks-per-node=2     # -N
#SBATCH --cpus-per-task=4       # -d

#SBATCH --time=00:10:00
#SBATCH --res=course

# benchmark configuration
export OMP_NUM_THREADS=4
NPROCS=8
CLASS=C
EXE=./bt-mz_$CLASS.$NPROCS


set -x
aprun -n $NPROCS -d $OMP_NUM_THREADS  $EXE


set +x
echo "# SLURM_NTASKS = $SLURM_NTASKS / -n --ntasks"
echo "# SLURM_NTASKS_PER_NODE = $SLURM_NTASKS_PER_NODE / -N --ntasks-per-node"
echo "# SLURM_CPUS_PER_TASK = $SLURM_CPUS_PER_TASK / -d --cpus-per-task"
echo "# OMP_NUM_THREADS = $OMP_NUM_THREADS / -d "
## echo "# SLURM_NTASKS_PER_CORE = $SLURM_NTASKS_PER_CORE / -j --ntasks-per-core"
