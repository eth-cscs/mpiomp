PREP=scorep

MPICC=cc
CC=cc
NVCC=nvcc -ccbin=cc

CFLAGS=-std=c99 -O3 -march=native
OMPCFLAGS=-DOMP_MEMLOCALTIY -fopenmp
CUDA_PATH=${CUDA_ROOT}
CUDACFLAGS=-I$(CUDA_PATH)/include
MPICFLAGS=-DUSE_MPI

NVCCFLAGS=-O3 -arch=sm_20 -Xcompiler -march=native

OMPLDFLAGS=-fopenmp -lm -lstdc++
CUDALDFLAGS=-L$(CUDA_PATH)/lib64 -lcudart

BINDIR=bin
JACOBI_OPENMP=$(BINDIR)/jacobi_openmp
JACOBI_CUDA=$(BINDIR)/jacobi_cuda
JACOBI_MPIOPENMP=$(BINDIR)/jacobi_mpi+openmp
JACOBI_MPICUDA=$(BINDIR)/jacobi_mpi+openmp+cuda
BINARIES=$(JACOBI_OPENMP) $(JACOBI_CUDA) $(JACOBI_MPIOPENMP) $(JACOBI_MPICUDA)

all: $(BINARIES)

$(BINDIR)/jacobi_cuda_kernel.o: src/jacobi_cuda_kernel.cu Makefile
	$(PREP) $(NVCC) $(NVCCFLAGS) -c src/jacobi_cuda_kernel.cu -o $(BINDIR)/jacobi_cuda_kernel.o

$(BINDIR)/jacobi_openmp.o: src/jacobi_openmp.c Makefile
	$(PREP) $(CC) $(CFLAGS) $(OMPCFLAGS) -c src/jacobi_openmp.c -o $(BINDIR)/jacobi_openmp.o
	
$(BINDIR)/jacobi_cuda.o: src/jacobi_cuda.c Makefile
	$(PREP) $(CC) $(CFLAGS) $(OMPCFLAGS) $(CUDACFLAGS) -c src/jacobi_cuda.c -o $(BINDIR)/jacobi_cuda.o
	#$(PREP) --cuda $(CC) $(CFLAGS) $(OMPCFLAGS) $(CUDACFLAGS) -c src/jacobi_cuda.c -o $(BINDIR)/jacobi_cuda.o
	
$(BINDIR)/jacobi_mpi+openmp.o: src/jacobi_openmp.c Makefile
	$(PREP) --mpp=mpi $(MPICC) $(CFLAGS) $(OMPCFLAGS) $(MPICFLAGS) -c src/jacobi_openmp.c -o $(BINDIR)/jacobi_mpi+openmp.o
	
$(BINDIR)/jacobi_mpi+cuda.o: src/jacobi_cuda.c Makefile
	$(PREP) $(MPICC) $(CFLAGS) $(OMPCFLAGS) $(MPICFLAGS) $(CUDACFLAGS) -c src/jacobi_cuda.c -o $(BINDIR)/jacobi_mpi+cuda.o
	#$(PREP) --mpp=mpi --cuda $(MPICC) $(CFLAGS) $(OMPCFLAGS) $(MPICFLAGS) $(CUDACFLAGS) -c src/jacobi_cuda.c -o $(BINDIR)/jacobi_mpi+cuda.o
	
$(JACOBI_OPENMP): $(BINDIR)/jacobi_openmp.o Makefile
	$(PREP) $(CC) $(OMPLDFLAGS) $(BINDIR)/jacobi_openmp.o -o $(JACOBI_OPENMP)
	
$(JACOBI_CUDA): $(BINDIR)/jacobi_cuda.o $(BINDIR)/jacobi_cuda_kernel.o Makefile
	$(PREP) --cuda $(CC) $(OMPLDFLAGS) $(CUDALDFLAGS) $(BINDIR)/jacobi_cuda.o $(BINDIR)/jacobi_cuda_kernel.o -o $(JACOBI_CUDA)

$(JACOBI_MPIOPENMP): $(BINDIR)/jacobi_mpi+openmp.o Makefile
	$(PREP) --mpp=mpi $(MPICC) $(OMPLDFLAGS) $(BINDIR)/jacobi_mpi+openmp.o -o $(JACOBI_MPIOPENMP)
	
$(JACOBI_MPICUDA): $(BINDIR)/jacobi_mpi+cuda.o $(BINDIR)/jacobi_cuda_kernel.o Makefile
	$(PREP) $(MPICC) $(OMPLDFLAGS) $(CUDALDFLAGS) $(BINDIR)/jacobi_mpi+cuda.o $(BINDIR)/jacobi_cuda_kernel.o -o $(JACOBI_MPICUDA)
	#$(PREP) --mpp=mpi --cuda $(MPICC) $(OMPLDFLAGS) $(CUDALDFLAGS) $(BINDIR)/jacobi_mpi+cuda.o $(BINDIR)/jacobi_cuda_kernel.o -o $(JACOBI_MPICUDA)
	
clean:
	rm -rf $(BINDIR)/*.o *opari* $(BINARIES)
