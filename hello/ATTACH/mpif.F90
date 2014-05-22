program who 
! ftn -g -D_ATTACH mpif.F90
        use mpi 
        implicit none
        integer :: nb_procs,rank,code,i,j,k=8, go=0
        character (len=MPI_MAX_PROCESSOR_NAME) :: n=""
        character (len=MPI_MAX_PROCESSOR_NAME) :: h=""
     
        call MPI_INIT (code)
        call MPI_COMM_SIZE ( MPI_COMM_WORLD ,nb_procs,code)
        call MPI_COMM_RANK ( MPI_COMM_WORLD ,rank,code)

#ifdef _ATTACH
if ( rank == 0 ) then
        do while (go /= 9)
! ATTACH debugger to RUNNING JOB
! INFINITE LOOP => echo 0 > go
!       TO STOP => echo 9 > go
        OPEN(UNIT=8,FILE='go',STATUS='OLD',FORM='FORMATTED',IOSTAT=code)
        READ(UNIT=8,FMT='(I1)',ADVANCE='NO',IOSTAT=code) go
        print *,'go=',go
        CLOSE(UNIT=8)
        call sleep(5)
        enddo
endif
#endif

        call MPI_Get_processor_name(n, k, code)
        call getenv("HOST", h)
        write(6,'(i4,i4,1x,a10,a10)') rank,nb_procs,n,h
        call MPI_FINALIZE (code)

end program who 
