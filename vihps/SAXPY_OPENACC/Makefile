CC = cc
LD = $(CC)
FC = $(CC)
FLAGS = -g 
PERFFLAGS = 
H := $(shell echo $(HOST) | tr [a-z] [A-Z] | tr -d [0-9] )

ifeq ($(PE_ENV),CRAY)
# ifneq ($(NVIDIA_POST_COMPILE_OPTS),-arch=sm_35)
ifneq ($(CRAY_ACCEL_TARGET),nvidia35)
        FLAGS += '---- YOU MUST LOAD craype-accel-nvidia35 ----'
endif
endif

# ifneq ($(CUDATOOLKIT_HOME),/opt/nvidia/cudatoolkit/5.5.20-1.0501.7945.8.2)
ifeq ($(PE_ENV),PGI)
ifneq ($(CUDATOOLKIT_HOME),/opt/nvidia/cudatoolkit/5.5.22-1.0502.7944.3.1)
        FLAGS += '---- YOU MUST LOAD cudatoolkit ----'
	#TODO: error('---- YOU MUST LOAD cudatoolkit ----')
endif
endif

# adding openacc compiler flag will define _OPENACC
ifeq ($(PE_ENV),PGI)
        FLAGS += -acc -ta=nvidia:cc35 -mcmodel=medium
endif

ifeq ($(PE_ENV),CRAY)
	# -hacc sets _OPENACC
        FLAGS += -G0 -hacc # -rmd
        # FLAGS += -G1 -hacc # -rmd
endif

FLAGS         += $(PERFFLAGS)
LDFLAGS        = $(FLAGS)
OBJ            = mpiacc_c.o
OBJ2 	       = $(subst mpiacc,$(PE_ENV)_mpiacc,$(OBJ))

LIB            = 
.SUFFIXES: .o .c .cpp .f90

%.o: %.c
	$(CC) $(FLAGS) $(DDTFLAGS) -c $< -o $(PE_ENV)_$@

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
