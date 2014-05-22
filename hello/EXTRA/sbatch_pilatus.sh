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
cpcn=`scontrol show nodes |grep -m1 CPUTot |awk '{print $1}'|cut -d= -f2`
mppnppn="${5:-$cpcn}"
if [ $mppnppn -gt $mppwidth ] ; then mppnppn=$mppwidth ; fi
mppdepth="${6:-1}"
if [ $mppdepth -gt 1 ] ; then isomp='export MV2_ENABLE_AFFINITY=0' ; else isomp='export MV2_ENABLE_AFFINITY=1' ; fi
numtasks=`expr $mppwidth \* $mppdepth | xargs printf "%04d\n"`
argsexe=$7
cnodes=`perl -e "use POSIX qw(ceil);printf \"%d\n\",ceil($mppwidth/$mppnppn)"`
oexe=`basename $exe`
out=runme.slurm.$cluster.$exe

######    ###   #          #    ####### #     #  #####
#     #    #    #         # #      #    #     # #     #
#     #    #    #        #   #     #    #     # #
######     #    #       #     #    #    #     #  #####
#          #    #       #######    #    #     #       #
#          #    #       #     #    #    #     # #     #
#         ###   ####### #     #    #     #####   #####
cat <<EOF > $out
#!/bin/bash
# !!! SBATCH -N == SALLOC -N /= APRUN -N !!!
#SBATCH -N $cnodes
#SBATCH -n $mppwidth
#SBATCH --tasks-per-node=$mppnppn
####SBATCH -d $mppdepth
#SBATCH --cpu_bind=verbose
#SBATCH --time=00:$T:00
#SBATCH --job-name="course"
#SBATCH --output=o_$oexe.$numtasks.$mppnppn.$mppdepth.$cnodes.$cluster
#SBATCH --error=o_$oexe.$numtasks.$mppnppn.$mppdepth.$cnodes.$cluster

export OMP_NUM_THREADS=$mppdepth
export MPICH_CPUMASK_DISPLAY=1
export MPICH_VERSION_DISPLAY=1
ulimit -c unlimited
ulimit -s unlimited
# ulimit -a 
# export MPICH_ENV_DISPLAY=1
# export MPICH_NO_BUFFER_ALIAS_CHECK=1
# echo "SLURM_JOB_NAME=\$SLURM_JOB_NAME" "SLURM_JOBID=\$SLURM_JOBID SLURM_JOB_ID=\$SLURM_JOB_ID SLURM_TASK_PID=\$SLURM_TASK_PID OMP_NUM_THREADS=\$OMP_NUM_THREADS"

# bindings ====================================
# 1 enables CPU affinity, for MPI+OpenMP, set to 0 :
$isomp
# *** Intel Only ***
# export KMP_AFFINITY=scatter,verbose
# export KMP_AFFINITY=compact,verbose
# export KMP_AFFINITY="verbose,granularity=fine,proclist=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31],explicit"
# http://software.intel.com/en-us/articles/using-kmp_affinity-to-create-openmp-thread-mapping-to-os-proc-ids/
# =============================================

date
echo "submit command : $cmd"
echo "w=$mppwidth pn=$mppnppn d=$mppdepth cn=$cnodes"
/usr/bin/time -p srun $exe $argsexe

EOF

 #####  ######     #    #######  #####  #     #
#     # #     #   # #      #    #     # #     #
#       #     #  #   #     #    #       #     #
 #####  ######  #     #    #    #       #######
      # #     # #######    #    #       #     #
#     # #     # #     #    #    #     # #     #
 #####  ######  #     #    #     #####  #     #
sbatch $out
grep "srun command" $out

exit 0
