#!/bin/bash
#SBATCH --ntasks=2              # -n
#SBATCH --ntasks-per-node=1     # -N
#SBATCH --cpus-per-task=1       # -d
#SBATCH --ntasks-per-core=1 # -j    # --ntasks-per-core / -j"
#
#SBATCH --time=00:01:00
#SBATCH --job-name="staff"
#SBATCH --output=o_
#SBATCH --error=o_

set +x
/usr/bin/time -p  aprun -n 2 -N 1 -d 1 -j 1  CRAY.SANTIS 256 
