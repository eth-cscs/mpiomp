// --- CSCS (Swiss National Supercomputing Center) ---

#include <stdlib.h>
#include <stdio.h>
#ifdef _OPENMP
#include <omp.h>
#endif

int main( int argc, char *argv[] )
{
#ifdef _OPENMP
        printf("this is OPENMP version %d\n",_OPENMP);
#else
        printf("no openmp");
#endif

        return 0;
}
