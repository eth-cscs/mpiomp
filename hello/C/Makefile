CC     = cc
FFLAGS = -g  # -Wl,"-zmuldefs"
H := $(shell echo $(HOST) | tr [a-z] [A-Z] | tr -d [0-9] )

# add -openmp compiler flag will define _OPENMP
ifeq ($(PE_ENV),PGI)
        FFLAGS += -mp -w 
        CFLAGS += $(FFLAGS)
endif

ifeq ($(PE_ENV),GNU)
        FFLAGS += -fopenmp -ggdb
        CFLAGS += $(FFLAGS)
endif

ifeq ($(PE_ENV),CRAY)
        FFLAGS += -G0 -homp
        CFLAGS += $(FFLAGS) # -h msglevel_4 
endif

ifeq ($(PE_ENV),INTEL)
        FFLAGS += -openmp -debug full
        CFLAGS += $(FFLAGS)
endif

LDFLAGS        = $(FFLAGS)
OBJ            = mpiompc.o
LIB            = 
.SUFFIXES: .o .c

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $(PE_ENV)_$@

$(PE_ENV).$(H): $(OBJ)
	$(CC) $(LDFLAGS) $(PE_ENV)_$< $(LIB) -o $@
	@echo $(PE_ENV) / $(H) / c executable ready

clean:
	rm -f *.o o_* runme.slurm.* *.$(H) 
