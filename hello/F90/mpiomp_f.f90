! --- CSCS (Swiss National Supercomputing Center) ---

program mpiomp_f

        use mpi
        implicit none
        integer :: ierr, rank, size, len, threads_cscs,  thread_cscs
        character(len=20) :: namecn
        integer :: omp_get_num_threads;
        integer :: omp_get_thread_num; 
        integer :: cscs_mpi_v, cscs_mpi_subv
        call MPI_GET_VERSION(cscs_mpi_v, cscs_mpi_subv, ierr)
        print *,"MPI version", cscs_mpi_v, cscs_mpi_subv, ierr
        call MPI_INIT ( ierr )
        call MPI_COMM_SIZE (MPI_COMM_WORLD, size, ierr)
        call MPI_COMM_RANK (MPI_COMM_WORLD, rank, ierr)
        call MPI_Get_processor_name(namecn, len, ierr);
        !$omp parallel private(thread_cscs)
        threads_cscs = omp_get_num_threads();
        thread_cscs = omp_get_thread_num(); 
        print*, "hello in c rnk=", rank, "/", size, "thd= ", thread_cscs, "/", threads_cscs, "n=", namecn
        !$omp end parallel
        call MPI_FINALIZE ( ierr )
end program mpiomp_f
