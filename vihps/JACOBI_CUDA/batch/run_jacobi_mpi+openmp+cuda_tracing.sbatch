#!/bin/bash -l

#SBATCH -J jacobi             # Job name
#SBATCH -o output_%j          # Name of stdout output file (%j expands to jobId)
#SBATCH --nodes=2             # Nodes
#SBATCH --ntasks=2            # MPI
#SBATCH --ntasks-per-node=1   #
#SBATCH --cpus-per-task=2     # OMP
#SBATCH -t 00:10:00           # Run time (hh:mm:ss) - 10 min

# Launch the MPI executable named "jacobi_mpi+openmp+cuda"

export OMP_NUM_THREADS=2
export SCOREP_EXPERIMENT_DIRECTORY=trace_mpi_openmp_cuda
export SCOREP_CUDA_ENABLE=yes
export SCOREP_ENABLE_PROFILING=false
export SCOREP_ENABLE_TRACING=true
export SCOREP_CUDA_BUFFER=512M
#export SCOREP_VERBOSE=1
#export SCOREP_DEBUG=cuda

aprun -N 1 -n 2 -d $OMP_NUM_THREADS ../bin/jacobi_mpi+openmp+cuda 4096 4096 0.15

