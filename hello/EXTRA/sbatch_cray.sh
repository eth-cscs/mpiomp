#!/bin/bash

# usage
if [ $# -lt 3 ] ; then 
   echo "USAGE : arg1=machine arg2=walltime arg3=exe"
   echo "        arg4=mppwidth arg5=mppnppn arg6=mppdepth"
   echo "        arg7=argsexe"
   exit 0
fi

# compute # of required compute nodes
function ceiling() {
    cn=`echo $1 $2 |awk '{print ($1/$2)}'`
    awk -vcn=$1 'function ceiling(x){return (x == int(x)) ? x : int(x)+1 }
    BEGIN{ print ceiling(cn) }'
}

# parse user arguments
cmd=`echo $0 "$@"`
cluster="$1"
T="$2"
exe="$3"
mppwidth="$4"
cpcn=`xtprocadmin -A |cut -c1-85| grep -m 1 compute|awk '{print $7}'`
mppnppn="${5:-$cpcn}"
if [ $mppnppn -gt $mppwidth ] ; then mppnppn=$mppwidth ; fi
mppdepth="${6:-1}"
numtasks=`expr $mppwidth \* $mppdepth | xargs printf "%04d\n"`
argsexe=$7
cnodes=`perl -e "use POSIX qw(ceil);printf \"%d\n\",ceil($mppwidth/$mppnppn)"`
oexe=`basename $exe`
out=runme.slurm.$cluster.$exe

 #####  ######     #    #     #
#     # #     #   # #    #   #
#       #     #  #   #    # #
#       ######  #     #    #
#       #   #   #######    #
#     # #    #  #     #    #
 #####  #     # #     #    #
cat <<EOF > $out
#!/bin/bash
# !!! SBATCH -N == SALLOC -N /= APRUN -N !!!
#SBATCH -N $cnodes
#SBATCH -n $mppwidth
#SBATCH --tasks-per-node=$mppnppn
#SBATCH -d $mppdepth
#SBATCH --time=00:$T:00
#SBATCH --job-name="course"
#SBATCH --output=o_$oexe.$numtasks.$mppnppn.$mppdepth.$cnodes.$cluster
#SBATCH --error=o_$oexe.$numtasks.$mppnppn.$mppdepth.$cnodes.$cluster

export MALLOC_MMAP_MAX=0
export MALLOC_TRIM_THRESHOLD_=536870912
export OMP_NUM_THREADS=$mppdepth
export MPICH_VERSION_DISPLAY=1
ulimit -c unlimited
ulimit -s unlimited
# ulimit -a 
# export MPICH_ENV_DISPLAY=1
# export MPICH_NO_BUFFER_ALIAS_CHECK=1
# echo "SLURM_JOB_NAME=\$SLURM_JOB_NAME" "SLURM_JOBID=\$SLURM_JOBID SLURM_JOB_ID=\$SLURM_JOB_ID SLURM_TASK_PID=\$SLURM_TASK_PID OMP_NUM_THREADS=\$OMP_NUM_THREADS"

date
echo "submit command : $cmd"
echo "w=$mppwidth pn=$mppnppn d=$mppdepth cn=$cnodes"
/usr/bin/time -p aprun -B $exe $argsexe 

EOF

 #####  ######     #    #######  #####  #     #
#     # #     #   # #      #    #     # #     #
#       #     #  #   #     #    #       #     #
 #####  ######  #     #    #    #       #######
      # #     # #######    #    #       #     #
#     # #     # #     #    #    #     # #     #
 #####  ######  #     #    #     #####  #     #
sbatch $out
grep "aprun command" $out

exit 0
