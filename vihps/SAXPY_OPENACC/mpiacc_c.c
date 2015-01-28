// --- CSCS (Swiss National Supercomputing Center) ---

#include <stdio.h>
#include <stdlib.h>

#include <omp.h>
#include <mpi.h>

void set(double *a, double *b, double *c, int N);
void saxpy( int n, double a, double *x, double *y);

void run(int rank, const int N)
{
    // initialize application
    MPI_Barrier(MPI_COMM_WORLD);
    double b[N];
    double c[N]; // = reinterpret_cast<double*>(malloc(N*sizeof(double)));

//    set(a,b,c,N);
    #pragma omp parallel for
    for(int i=0; i<N; i++){
        c[i] = i*100.0;
    }
    printf("c[0]=%f\n", c[0]);
    printf("c[N-1]=%f\n", c[N-1]);
//    std::cout << "c[1]=" << c[1] << std::endl;
//    std::cout << "c[N/2]=" << c[N/2] << std::endl;
//    std::cout << "c[N-1]=" << c[N-1] << std::endl;

#ifdef _OPENACC
    printf("_OPENACC version: %d\n", _OPENACC);    
    saxpy(N, 1.0, b, c);
#endif

    printf("c[0]=%f\n", c[0]);
    printf("c[N-1]=%f\n", c[N-1]);

//    std::cout << "c[0]=" << c[0] << std::endl;
//    std::cout << "c[1]=" << c[1] << std::endl;
//    std::cout << "c[N/2]=" << c[N/2] << std::endl;
//    std::cout << "c[N-1]=" << c[N-1] << std::endl;

//    free(a);
//    free(b);
//    free(c);
}
 


int main(int argc, char **argv){
    // init mpi
    int rank = 0, size = 1;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    //const int N = 4600;
    int N = atoi(argv[1]);  //argv[0] is the program name
    if(!rank) printf("using MPI with %d PEs, N=%d\n", size, N);
    run(rank, N);

    // finalize MPI
    MPI_Finalize();

   return 0;
}

void set(double *a, double *b, double *c, int N) {
//    #pragma omp parallel for
    for(int i=0; i<N; i++){
        a[i] = 2.;
        b[i] = i*1.0;
        c[i] = i*100.0;
    }
}

void saxpy( int n, double a, double *x, double *y){
    int i;
    #pragma acc parallel loop pcopyin(x[0:n-1]) pcopyout(y[0:n-1])
    for( i = 0; i < n; ++i )
        y[i] += a*x[i];
}
