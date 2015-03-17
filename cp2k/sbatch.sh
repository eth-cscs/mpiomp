#!/bin/bash -l
# -l will set modulecmd

if [ $# -lt 3 ] ; then 
   echo "USAGE : arg1=machine arg2=walltime arg3=exe arg4=mppwidth" 
   echo "               [arg5=mppnppn] [arg6=mppdepth] [arg7=args]"
   echo "     [arg8=preaprun] [arg9=postaprun] [arg10=sbatchflags]"
   echo "     [arg11=callstack,outputpostfix] [arg12=hyperthreading] "
   exit 0
fi




function ceiling() {

    cn=`echo $1 $2 |awk '{print ($1/$2)}'`
    awk -vcn=$1 'function ceiling(x){return (x == int(x)) ? x : int(x)+1 }
    BEGIN{ print ceiling(cn) }'

    #awk -vnumber="$numtasks" -vdiv="$mppnppn" '
    #function ceiling(x){return (x == int(x)) ? x : int(x)+1 }
    #BEGIN{ print ceiling(number/div) }'

}

cmd=`echo $0 "$@"`
cluster="$1"
if [ -z $cluster ] ; then
        cluster=`hostname |tr -d [0-9]`
        goto=
else
        if [ ! $cluster = "brisi" ] ; then
                #goto="--clusters=$cluster"
                goto="--clusters=$cluster"
        else 
                goto=
        fi
fi

T="$2"
exe="$3"
mppwidth="$4"

if [ $cluster != "rothorn" ] && [ $cluster != "pilatus" ] && [ $cluster != "monch" ] ; then
        cpcn=`xtprocadmin -A |cut -c1-85| grep -m 1 compute|awk '{print $7}'`
        mppnppn="${5:-$cpcn}"
        if [ $mppnppn -gt $mppwidth ] ; then mppnppn=$mppwidth ; fi
        #if [ $mppnppn -lt $cpcn ] ; then mppnppn=$mppwidth ; fi
elif [ $cluster = "rothorn" ] ; then
        cpcn=256
        mppnppn="${5:-$cpcn}"

elif [ $cluster = "pilatus" ] ; then
        cpcn=32
        mppnppn="${5:-$cpcn}"
elif [ $cluster = "monch" ] ; then
        cpcn=40
        mppnppn="${5:-$cpcn}"
fi
# fi

mppdepth="${6:-1}"
# if [ -z $mppdepth ] ;then mppdepth=1 ; fi

numtasks=`expr $mppwidth \* $mppdepth | xargs printf "%04d\n"`
numtask=`echo $mppwidth | xargs printf "%d\n"`

argsexe=$7

preaprun=$8

postaprun=$9

sbatchflags=${10}
postfix=${11}
hyperthreading=${12}
if [ -z $hyperthreading ] ; then hyperthreading=1 ; fi
if [ $cluster = "santis" ] || [ $cluster = "daint" ] || [ $cluster = "brisi" ] || [ $cluster = "dora" ]; then
        ht1="#SBATCH --ntasks-per-core=$hyperthreading # -j"
        ht2="-j $hyperthreading"
fi


#echo "$mppwidth/$mppnppn"
cnodes=`perl -e "use POSIX qw(ceil);printf \"%d\n\",ceil($mppwidth/$mppnppn)"`
#cnodes=`awk -v n=$mppwidth -v N=$mppnppn 'function ceiling(x){return (x == int(x)) ? x : int(x)+1 }BEGIN{print ceiling($n/$N)}'`
#cnodes=`ceiling`
#echo "mppwidth=$mppwidth mppnppn=$mppnppn mppdepth=$mppdepth cpcn=$cpcn @ cnodes=$cnodes"
#exit 0
#==========================> cnodes=`ceiling`
oexe=`basename $exe`
out=runme.slurm.$cluster

 #####  ######     #    #     #
#     # #     #   # #    #   #
#       #     #  #   #    # #
#       ######  #     #    #
#       #   #   #######    #
#     # #    #  #     #    #
 #####  #     # #     #    #
if [ $cluster != "rothorn" ] && [ $cluster != "pilatus" ] && [ $cluster != "monch" ] ; then
cat <<EOF > $out
#!/bin/bash
##SBATCH --nodes=$cnodes
#
#SBATCH --ntasks=$numtask               # -n
#SBATCH --ntasks-per-node=$mppnppn      # -N
#SBATCH --cpus-per-task=$mppdepth       # -d
$ht1    # --ntasks-per-core / -j"
#
#SBATCH --time=00:$T:00
#SBATCH --job-name="staff"
#SBATCH --output=o_$oexe.$numtasks.$mppnppn.$mppdepth.$hyperthreading.$cluster.$postfix
#SBATCH --error=o_$oexe.$numtasks.$mppnppn.$mppdepth.$hyperthreading.$cluster.$postfix
##SBATCH --account=usup
####SBATCH --reservation=maint

echo '# -----------------------------------------------'
ulimit -c unlimited
ulimit -s unlimited
ulimit -a |awk '{print "# "\$0}'
echo '# -----------------------------------------------'

echo '# -----------------------------------------------'
# export MPICH_CPUMASK_DISPLAY=1        # = core of the rank
# The distribution of MPI tasks on the nodes can be written to the standard output file by setting environment variable 
# export MPICH_RANK_REORDER_DISPLAY=1   # = node of the rank
export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=536870912
export OMP_NUM_THREADS=$mppdepth
export MPICH_VERSION_DISPLAY=1
export MPICH_ENV_DISPLAY=1
#export PAT_RT_CALLSTACK_BUFFER_SIZE=50000000 # > 4194312
#export OMP_STACKSIZE=500M
#
# export PAT_RT_EXPFILE_MAX=99999
# export PAT_RT_SUMMARY=0
#
#export PAT_RT_TRACE_FUNCTION_MAX=1024 
#export PAT_RT_EXPFILE_PES
#export MPICH_PTL_MATCH_OFF=1
#export MPICH_PTL_OTHER_EVENTS=4096
#export MPICH_MAX_SHORT_MSG_SIZE=32000
#export MPICH_PTL_UNEX_EVENTS=180000
#export MPICH_UNEX_BUFFER_SIZE=284914560
#export MPICH_COLL_OPT_OFF=mpi_allgather
#export MPICH_COLL_OPT_OFF=mpi_allgatherv
export MPICH_NO_BUFFER_ALIAS_CHECK=1
#NEW export MPICH_MPIIO_STATS=1
echo '# -----------------------------------------------'


echo '# -----------------------------------------------'
echo "# SLURM_JOB_NODELIST = \$SLURM_JOB_NODELIST"
echo "# submit command : $cmd"
grep aprun $out
echo "# SLURM_JOB_NUM_NODES = \$SLURM_JOB_NUM_NODES"
echo "# SLURM_JOB_ID = \$SLURM_JOB_ID"
echo "# SLURM_JOBID = \$SLURM_JOBID"
echo "# SLURM_NTASKS = \$SLURM_NTASKS / -n --ntasks"
echo "# SLURM_NTASKS_PER_NODE = \$SLURM_NTASKS_PER_NODE / -N --ntasks-per-node"
echo "# SLURM_CPUS_PER_TASK = \$SLURM_CPUS_PER_TASK / -d --cpus-per-task"
echo "# OMP_NUM_THREADS = \$OMP_NUM_THREADS / -d "
echo "# SLURM_NTASKS_PER_CORE = \$SLURM_NTASKS_PER_CORE / -j1 --ntasks-per-core"
# sacct --format=JobID,NodeList%100 -j \$SLURM_JOB_ID
echo '# -----------------------------------------------'

export CRAY_CUDA_MPS=0
export PAT_RT_CALLSTACK=$postfix

date
set +x
/usr/bin/time -p $preaprun aprun -n $mppwidth -N $mppnppn -d $mppdepth $ht2 $postaprun $exe $argsexe 



EOF
fi


 #####  ######     #    #######  #####  #     #
#     # #     #   # #      #    #     # #     #
#       #     #  #   #     #    #       #     #
 #####  ######  #     #    #    #       #######
      # #     # #######    #    #       #     #
#     # #     # #     #    #    #     # #     #
 #####  ######  #     #    #     #####  #     #
# echo sbatch --clusters=$cluster $sbatchflags $out
#if [ -z $cluster ] ; then
#        sbatch                     $sbatchflags $out
#else
        sbatch $goto $sbatchflags $out
#fi
grep -E "aprun|mpirun|srun" $out |grep -v echo

exit 0

# xpat
export PAT_RT_HWPC=DATA_CACHE_REFILLS_FROM_L2_OR_NORTHBRIDGE
# scalasca
export EPK_METRICS=DATA_CACHE_REFILLS_FROM_L2_OR_NORTHBRIDGE
