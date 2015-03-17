#!/bin/bash
# submit from bin/ directory with "sbatch run.sbatch"

#SBATCH --job-name="bt-mpi+omp-16CN"
#SBATCH --ntasks=8              # -n
#SBATCH --ntasks-per-node=8     # -N
#SBATCH --cpus-per-task=1       # -d
#SBATCH --time=00:05:00         # minutes
#SBATCH --output=o
#SBATCH --error=o
###SBATCH --res=jpg

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK     # =2
set -x
/usr/bin/time -p aprun -n $SLURM_NTASKS -N $SLURM_NTASKS_PER_NODE -d $OMP_NUM_THREADS ./bt-mz_C.$SLURM_NTASKS

set +x
echo "# SLURM_NTASKS = $SLURM_NTASKS / -n --ntasks"
echo "# SLURM_NTASKS_PER_NODE = $SLURM_NTASKS_PER_NODE / -N --ntasks-per-node"
echo "# SLURM_CPUS_PER_TASK = $SLURM_CPUS_PER_TASK / -d --cpus-per-task"
echo "# OMP_NUM_THREADS = $OMP_NUM_THREADS / -d "
## echo "# SLURM_NTASKS_PER_CORE = $SLURM_NTASKS_PER_CORE / -j --ntasks-per-core"
###SBATCH --output=o_%j           # %j = $SLURM_JOBID
###SBATCH --error=o_%j            # stderr => stdout 
