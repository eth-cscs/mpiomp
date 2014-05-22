// --- CSCS (Swiss National Supercomputing Center) ---

#include <stdlib.h>
#include <stdio.h>
#ifdef _OPENMP
#include <omp.h>
#endif

int main( int argc, char *argv[] )
{
        int rank=0, size=0, thread_cscs=0, threads_cscs=0, len=0 ;
#ifdef _OPENMP
        printf("this is OPENMP version %d\n",_OPENMP);
#endif

        return 0;
}
