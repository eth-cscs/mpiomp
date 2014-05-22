CC = CC
FC = ftn
LD = $(FC)
FLAGS = -g 
H := $(shell echo $(HOST) | tr [a-z] [A-Z] | tr -d [0-9] )


# adding openacc compiler flag will define _OPENACC
ifeq ($(PE_ENV),PGI)
        FLAGS += -mp -w
endif
ifeq ($(PE_ENV),GNU)
        FLAGS += -fopenmp -ggdb
endif

ifeq ($(PE_ENV),CRAY)
        FLAGS += -G0 -homp # -rmd

endif
ifeq ($(PE_ENV),INTEL)
        FLAGS += -openmp -debug full # -rmd

endif


LDFLAGS        = $(FLAGS)
OBJ            = mpiomp_f.o
OBJ2 	       = $(subst mpiomp_f,$(PE_ENV)_mpiomp_f,$(OBJ))

LIB            = 
.SUFFIXES: .o .cpp .f90

%.o: %.cpp
	$(CC) $(FLAGS) $(DDTFLAGS) -c $< -o $(PE_ENV)_$@

%.o: %.f90
	$(FC) $(FLAGS) $(DDTFLAGS) -c $< -o $(PE_ENV)_$@

$(PE_ENV).$(H): $(OBJ)
	$(LD) $(LDFLAGS) $(OBJ2) $(LIB) -o $@
	@echo $(PE_ENV) / $(H) / openacc executable ready

clean:
	rm -f *.o o_* runme.slurm.* *.$(H) 
	rm -fr *.ptx *.opt *.cg *.ap2 *.rpt *.cub *.lst *.xf
