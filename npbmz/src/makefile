include ../config/make.def
#include ../sys/make.common
PROGRAM  = $(BINDIR)/$(BENCHMARK).$(CLASS).$(NPROCS)
FCOMPILE = $(F77) -c $(F_INC) $(FFLAGS)
CCOMPILE = $(CC)  -c $(C_INC) $(CFLAGS)
SHELL=/bin/sh
CLASS=W
NPROCS=1
VERSION=
H := $(shell echo $(HOST) | tr [a-z] [A-Z] | tr -d [0-9] )

OBJS = bt.o initialize.o exact_solution.o exact_rhs.o \
       set_constants.o adi.o  rhs.o zone_setup.o  \
       x_solve.o y_solve.o  exch_qbc.o solve_subs.o \
       z_solve.o add.o error.o verify.o mpi_setup.o \
       print_results.o timers.o

#all: clean setparams npbparams.h bt-mz
#default: init setparams npbparams.h bt-mz
default: init setparams npbparams.h $(PE_ENV).$(H)

init:
	rm -f npbparams.h

setparams: ../sys/setparams.c
	cd ../sys ; gcc -o setparams setparams.c -lm

npbparams.h: setparams
	../sys/setparams ${BENCHMARK} ${NPROCS} ${CLASS}
	@ echo "$< done" ; echo

# bt-mz: setparams $(OBJS)
$(PE_ENV).$(H): setparams $(OBJS)
	${FLINK} ${FLINKFLAGS} -o ../bin/$@.$(CLASS).$(NPROCS) ${OBJS} ${F_LIB}

.F.o:
	${FCOMPILE} $<

clean:
	- rm -f core $(OBJS)
	@ echo

help:
	@ ../sys/print_header

print_results.o:  print_results.F
timers.o:         timers.F
bt.o:             bt.F mpi_stuff.h header.h npbparams.h print_results.o timers.o
initialize.o:     initialize.F  header.h npbparams.h
exact_solution.o: exact_solution.F  header.h npbparams.h
exact_rhs.o:      exact_rhs.F  header.h npbparams.h
set_constants.o:  set_constants.F  header.h npbparams.h
adi.o:            adi.F  header.h npbparams.h
rhs.o:            rhs.F  header.h npbparams.h
zone_setup.o:     zone_setup.F mpi_stuff.h header.h npbparams.h
x_solve.o:  	  x_solve.F  header.h work_lhs.h npbparams.h
y_solve.o:  	  y_solve.F  header.h work_lhs.h npbparams.h
z_solve.o:        z_solve.F  header.h work_lhs.h npbparams.h
solve_subs.o:     solve_subs.F  npbparams.h
add.o:            add.F  header.h npbparams.h
error.o:          error.F  header.h npbparams.h
verify.o:         verify.F  mpi_stuff.h header.h npbparams.h
exch_qbc.o:       exch_qbc.F mpi_stuff.h header.h npbparams.h
mpi_setup.o:      mpi_setup.F  mpi_stuff.h header.h npbparams.h

