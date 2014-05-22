// --- CSCS (Swiss National Supercomputing Center) ---

#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>
#ifdef _OPENMP
#include <omp.h>
#endif

int main( int argc, char *argv[] )
{
        int rank=0, size=0, thread_cscs=0, threads_cscs=0, len=0 ;
        char namecn[MPI_MAX_PROCESSOR_NAME];
#ifdef _OPENMP
        printf("this is OPENMP version %d\n",_OPENMP);
#endif

        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        MPI_Get_processor_name(namecn, &len);
#pragma omp parallel private(thread_cscs)
        {
#ifdef _OPENMP
        threads_cscs = omp_get_num_threads();
        thread_cscs = omp_get_thread_num();
#endif
        printf("hello in c rnk= %4d / %4d thd= %4d / %4d n=%s\n", rank, size, thread_cscs, threads_cscs,namecn);
        }
        MPI_Finalize();
        return 0;
}
