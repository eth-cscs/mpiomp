#!/bin/bash

#SBATCH -J jacobi             # Job name
#SBATCH -o o_%j          # Name of stdout output file (%j expands to jobId)
#SBATCH -e o_%j          # Name of stderr output file (%j expands to jobId)
#SBATCH --nodes=2             # Nodes
#SBATCH --ntasks=2            # MPI
#SBATCH --ntasks-per-node=1   #
#SBATCH --cpus-per-task=2     # OMP
#SBATCH -t 00:10:00           # Run time (hh:mm:ss) - 10 min

# Launch the MPI executable named "jacobi_mpi+openmp+cuda"

export OMP_NUM_THREADS=2

aprun -N 1 -n 2 -d $OMP_NUM_THREADS ../bin/jacobi_mpi+openmp+cuda 4096 4096 0.15

