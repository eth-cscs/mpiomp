!-------------------------------------------------------------------------!
!                                                                         !
!        N  A  S     P A R A L L E L     B E N C H M A R K S  3.3         !
!                                                                         !
!             M P I    M U L T I - Z O N E    V E R S I O N               !
!                                                                         !
!                           B T - M Z - M P I                             !
!                                                                         !
!-------------------------------------------------------------------------!
!                                                                         !
!    This benchmark is an MPI+OpenMP version of the NPB BT code.          !
!    Refer to NAS Technical Reports 95-020 and 99-011 for details.        !
!                                                                         !
!    Permission to use, copy, distribute and modify this software         !
!    for any purpose with or without fee is hereby granted.  We           !
!    request, however, that all derived work reference the NAS            !
!    Parallel Benchmarks 3.3. This software is provided "as is"           !
!    without express or implied warranty.                                 !
!                                                                         !
!    Information on NPB 3.3, including the technical report, the          !
!    original specifications, source code, results and information        !
!    on how to submit new results, is available at:                       !
!                                                                         !
!           http://www.nas.nasa.gov/Software/NPB/                         !
!                                                                         !
!    Send comments or suggestions to  npb@nas.nasa.gov                    !
!                                                                         !
!          NAS Parallel Benchmarks Group                                  !
!          NASA Ames Research Center                                      !
!          Mail Stop: T27A-1                                              !
!          Moffett Field, CA   94035-1000                                 !
!                                                                         !
!          E-mail:  npb@nas.nasa.gov                                      !
!          Fax:     (650) 604-3957                                        !
!                                                                         !
!-------------------------------------------------------------------------!

!---------------------------------------------------------------------
!
! Authors: R. Van der Wijngaart
!          T. Harris
!          M. Yarrow
!          H. Jin
!
!---------------------------------------------------------------------

!---------------------------------------------------------------------
       program BT
!---------------------------------------------------------------------

#ifdef _PARALLEL_HDF5
       use hdf5
#endif

       include  'header.h'
       include  'mpi_stuff.h'

#ifdef _PARALLEL_HDF5
       !INTEGER(HSIZE_T), DIMENSION(2) :: dimsf = (/9000, 9000/) ! Dataset dimensions (300M)
       INTEGER(HSIZE_T), DIMENSION(2) :: dimsf = (/6000, 6000/) ! Dataset dimensions (130M)
       !INTEGER(HSIZE_T), DIMENSION(2) :: dimsf = (/3000, 3000/) ! Dataset dimensions (30M)
       !INTEGER(HSIZE_T), DIMENSION(2) :: dimsf = (/900, 900/) ! Dataset dimensions (3M)
       INTEGER, ALLOCATABLE :: data(:,:)   ! Data to write
       CHARACTER(LEN=100) :: filename  ! File name
       INTEGER        :: fnamelen      ! File name length
       INTEGER(HID_T) :: file_id       ! File identifier
       INTEGER(HID_T) :: dset_id       ! Dataset identifier
       INTEGER(HID_T) :: filespace     ! Dataspace identifier in file
       INTEGER(HID_T) :: plist_id      ! Property list identifier 
       INTEGER :: hdferr, j, info
       CHARACTER(LEN=8), PARAMETER :: dsetname = "IntArray" ! Dataset name
       INTEGER(HSIZE_T), DIMENSION(2) :: dimsfi
       INTEGER :: rankh5 = 2
       character(len=9) :: name_orig
#endif

#ifdef _PARALLEL_IO
       include 'H5PartF.h'
       integer(kind=8) :: file_id
       character(len=9) :: name_orig
       integer :: rank=0, positives=0
       integer(kind=8), parameter :: np_max = 2500
       real(kind=8) :: np(np_max)=0.0
       integer(kind=8), parameter :: io_max = 1000000
       real(kind=8) :: io(io_max)=0.0
#endif
       integer num_zones
       parameter (num_zones=x_zones*y_zones)

       integer   nx(num_zones), nxmax(num_zones), ny(num_zones), 
     $           nz(num_zones)

!---------------------------------------------------------------------
!   Define all field arrays as one-dimenional arrays, to be reshaped
!---------------------------------------------------------------------
       double precision 
     >   u       (proc_max_size5),
     >   us      (proc_max_size ),
     >   vs      (proc_max_size ),
     >   ws      (proc_max_size ),
     >   qs      (proc_max_size ),
     >   rho_i   (proc_max_size ),
     >   square  (proc_max_size ),
     >   rhs     (proc_max_size5),
     >   forcing (proc_max_size5),
     >   qbc_ou  (proc_max_bcsize), 
     >   qbc_in  (proc_max_bcsize)

       common /fields/ u, us, vs, ws, qs, rho_i, square, 
     >                 rhs, forcing, qbc_ou, qbc_in

       integer          i, niter, step, fstatus, zone, 
     >                  iz, ip, tot_threads, itimer
       double precision navg, mflops, nsur, n3

       external         timer_read
       double precision tmax, timer_read, t, trecs(t_last)
       logical          verified
       character        t_names(t_last)*8
#ifdef _ATTACH
       integer          go, cscs
       go=0
       cscs=0
#endif
        


       call mpi_setup
       if (.not. active) goto 999

! -- CSCS: infinite loop to let debugger attach to running job
#ifdef _ATTACH
        if ( myid == 0 ) then
        do while (go /= 9)
! ATTACH debugger to RUNNING JOB
! INFINITE LOOP => echo 0 > go
!       TO STOP => echo 9 > go
        OPEN(UNIT=8,FILE='go',STATUS='OLD',FORM='FORMATTED',IOSTAT=cscs)
        READ(UNIT=8,FMT='(I1)',ADVANCE='NO',IOSTAT=cscs) go
        print *,'go=',go
        CLOSE(UNIT=8)
        call sleep(5)
        enddo
        endif
#endif
! -- CSCS: infinite loop to let debugger attach to running job

!---------------------------------------------------------------------
!      Root node reads input file (if it exists) else takes
!      defaults from parameters
!---------------------------------------------------------------------
       if (myid .eq. root) then

         write(*, 1000)
         open (unit=2,file='inputbt-mz.data',status='old', 
     >         iostat=fstatus)

         timeron = .false.
         if (fstatus .eq. 0) then
           write(*,*) 'Reading from input file inputbt-mz.data'
           read (2,*) niter
           read (2,*) dt
           read (2,*) itimer
           close(2)

           if (niter .eq. 0)  niter = niter_default
           if (dt .eq. 0.d0)  dt    = dt_default
           if (itimer .gt. 0) timeron = .true.

         else
           niter = niter_default
           dt    = dt_default
         endif

         write(*, 1001) x_zones, y_zones
         write(*, 1002) niter, dt
         write(*, 1003) num_procs
       endif
 1000  format(//, ' NAS Parallel Benchmarks (NPB3.3-MZ-MPI)',
     >            ' - BT-MZ MPI+OpenMP Benchmark', /)
 1001  format(' Number of zones: ', i3, ' x ', i3)
 1002  format(' Iterations: ', i3, '    dt: ', F10.6)
 1003  format(' Number of active processes: ', i5/)

       call mpi_bcast(niter, 1, MPI_INTEGER,
     >                root, comm_setup, ierror)
       call mpi_bcast(dt, 1, dp_type,
     >                root, comm_setup, ierror)
       call mpi_bcast(timeron, 1, MPI_LOGICAL,
     >                root, comm_setup, ierror)

       if (timeron) then
         t_names(t_total) = 'total'
         t_names(t_rhsx) = 'rhsx'
         t_names(t_rhsy) = 'rhsy'
         t_names(t_rhsz) = 'rhsz'
         t_names(t_rhs) = 'rhs'
         t_names(t_xsolve) = 'xsolve'
         t_names(t_ysolve) = 'ysolve'
         t_names(t_zsolve) = 'zsolve'
         t_names(t_rdis1) = 'qbc_copy'
         t_names(t_rdis2) = 'qbc_comm'
         t_names(t_add) = 'add'
       endif

       call env_setup(tot_threads)

       call zone_setup(nx, nxmax, ny, nz)

       call map_zones(num_zones, nx, ny, nz, tot_threads)
       call zone_starts(num_zones, nx, nxmax, ny, nz)

       call set_constants

       do iz = 1, proc_num_zones
         zone = proc_zone_id(iz)

         call initialize(u(start5(iz)),
     $                   nx(zone), nxmax(zone), ny(zone), nz(zone))
         call exact_rhs(forcing(start5(iz)),
     $                  nx(zone), nxmax(zone), ny(zone), nz(zone))

       end do

       do i = 1, t_last
          call timer_clear(i)
       end do

!---------------------------------------------------------------------
!      do one time step to touch all code, and reinitialize
!---------------------------------------------------------------------

       call exch_qbc(u, qbc_ou, qbc_in, nx, nxmax, ny, nz, 
     $               npb_verbose)

       do iz = 1, proc_num_zones
         zone = proc_zone_id(iz)
         call adi(rho_i(start1(iz)), us(start1(iz)), 
     $            vs(start1(iz)), ws(start1(iz)), 
     $            qs(start1(iz)), square(start1(iz)), 
     $            rhs(start5(iz)), forcing(start5(iz)), 
     $            u(start5(iz)), 
     $            nx(zone), nxmax(zone), ny(zone), nz(zone))
       end do

       do iz = 1, proc_num_zones
         zone = proc_zone_id(iz)
         call initialize(u(start5(iz)), 
     $                   nx(zone), nxmax(zone), ny(zone), nz(zone))
       end do

       do i = 1, t_last
          call timer_clear(i)
       end do
       call mpi_barrier(comm_setup, ierror)

       call timer_start(1)

!---------------------------------------------------------------------
!      start the benchmark time step loop
!---------------------------------------------------------------------

       do step = 1, niter

         !if (mod(step, 20) .eq. 0 .or. step .eq. 1) then
         if (mod(step, 10) .eq. 0 .or. step .eq. 1) then
            if (myid .eq. root) write(*, 200) step
 200        format(' Time step ', i4)
         endif

         call exch_qbc(u, qbc_ou, qbc_in, nx, nxmax, ny, nz, 
     $                 0)

         do iz = 1, proc_num_zones
           zone = proc_zone_id(iz)
           call adi(rho_i(start1(iz)), us(start1(iz)), 
     $              vs(start1(iz)), ws(start1(iz)), 
     $              qs(start1(iz)), square(start1(iz)), 
     $              rhs(start5(iz)), forcing(start5(iz)), 
     $              u(start5(iz)), 
     $              nx(zone), nxmax(zone), ny(zone), nz(zone))
         end do

!---------------------------------------------------------------------
!      write out some data
!---------------------------------------------------------------------
#ifdef _PARALLEL_IO
! module load PrgEnv-gnu cray-hdf5-parallel/1.8.9 perftools/6.0.1
! mm -j6 NPROCS=4 CLASS=B FFLAGS="-D_PARALLEL_IO
! -I/apps/rosa/sandbox/jgp/h5part/1.6.6/gnu_472/include"
! F_LIB="-L/apps/rosa/sandbox/jgp/h5part/1.6.6/gnu_472/lib -lH5PartF"
        call MPI_COMM_RANK ( MPI_COMM_WORLD ,rank,ierror)
        !if ( rank .eq. 0 ) then

!                do iz=1,size(u)
!                        if (u(iz).gt.1e-3) then 
!                                positives=positives+1
!                                if (positives .lt. np_max) then 
!                                np(positives) = u(iz)
!                                endif
!                       endif
!                enddo
!                !print *,rank,'A',size(io),maxval(io),positives,ierror 
!                io(1:io_max)=np(1:io_max)
                 !io(1:io_max)=1.0
                 io(1:io_max)=u(1:io_max)
        !        print *,rank,'B',size(io),maxval(io),positives,ierror 
        !endif ! rk=0
        !if ( (mod(step,5) .eq. 0) .and. (mod(rank,32) .eq. 0) ) then
        !if ( (mod(step,5) .eq. 0) .and. (rank .eq. 0) ) then
        if ( (mod(step,25) .eq. 0) ) then

                ! this enables level 4 ("debug") messages to be
                ! printed by the H5Part library
                ! (4_8 is integer*8 with value 4)
                !ierror = h5pt_set_verbosity_level (4_8) 
                ierror = h5pt_set_verbosity_level (1_8) 
                !print *,"262:",ierror,"/",rank

                ! open a file called 'PART_nnnn' in parallel for writing
                write(unit=name_orig, fmt='(a5,i4.4)') "HDF5_",step
                file_id = h5pt_openw_par (name_orig, MPI_COMM_WORLD)
                !file_id = h5pt_openw (name_orig)
                !file_id = h5pt_openw_par (name_orig, comm_setup)
                ! in the Fortran API, steps start at 1_kind8
                !ierror = h5pt_setstep (file_id, stepr8)
                ierror = h5pt_setstep (file_id, 1_8)
                !print *,"268:",ierror,"/",rank

                ! write an attribute to the file
                ierror = h5pt_writefileattrib_string (file_id, 'desc', 
     >                                                    'simple io')
                !print *,"272:",ierror,"/",rank

                ! set the size of the data array
                ierror = h5pt_setnpoints (file_id, io_max)
                !print *,"275:",ierror,"/",rank
                !ierror = h5pt_setnpoints (file_id, positives)

                ! write the data (r4 or r8)
                ierror = h5pt_writedata_r8(file_id, "io", io)
                !ierror = h5pt_writedata_r8(file_id, "io", 1_8)
                !ierror = h5pt_writedata_r8(file_id, "io", io)
                !print *,"280:",ierror,"/",rank
                !print *,rank,'@',size(io),maxval(io),positives,ierror 
                !deallocate(io)
                ! close the file
                !call MPI_Barrier(MPI_COMM_WORLD,ierror)
                ierror = h5pt_close (file_id)
        endif

#endif

       enddo ! step

       call timer_stop(1)
       tmax = timer_read(1)

!---------------------------------------------------------------------
!      write out some data
!---------------------------------------------------------------------
#ifdef _PARALLEL_HDF5
        ALLOCATE ( data(dimsf(1),dimsf(2)))
        do i = 1, dimsf(2)
         do j = 1, dimsf(1)
                data(j,i) = j - 1 + (i-1)*dimsf(1)
         enddo
        enddo

        ! open a file called 'PART_nnnn' in parallel for writing
        write(unit=name_orig, fmt='(i4.4, a5)') step,"_o.h5"
        info = MPI_INFO_NULL
        CALL h5open_f( hdferr )
        CALL h5pcreate_f(H5P_FILE_ACCESS_F, plist_id, hdferr)
        CALL h5pset_fapl_mpio_f(plist_id, MPI_COMM_WORLD, info, hdferr)
        CALL h5fcreate_f(name_orig, H5F_ACC_TRUNC_F, file_id, hdferr, 
     &           access_prp = plist_id)
        CALL h5pclose_f(plist_id, hdferr)
        CALL h5screate_simple_f(rankh5, dimsf, filespace, hdferr)
        CALL h5dcreate_f(file_id, dsetname, H5T_NATIVE_INTEGER, 
     &          filespace, dset_id, hdferr)
        CALL h5pcreate_f(H5P_DATASET_XFER_F, plist_id, hdferr)
        CALL h5pset_dxpl_mpio_f(plist_id,H5FD_MPIO_COLLECTIVE_F,hdferr)
        CALL h5dwrite_f(dset_id, H5T_NATIVE_INTEGER, data, dimsfi, 
     &          hdferr, xfer_prp = plist_id)
        DEALLOCATE(data)
        CALL h5sclose_f(filespace, hdferr)
        CALL h5dclose_f(dset_id, hdferr)
        CALL h5pclose_f(plist_id, hdferr)
        CALL h5fclose_f(file_id, hdferr)
        CALL h5close_f(hdferr)
#endif


!---------------------------------------------------------------------
!      perform verification and print results
!---------------------------------------------------------------------
       
       call verify(niter, verified, num_zones, rho_i, us, vs, ws, 
     $             qs, square, rhs, forcing, u, nx, nxmax, ny, nz)

       t = tmax
       call mpi_reduce(t, tmax, 1, dp_type, MPI_MAX, 
     >                 root, comm_setup, ierror)

       if (myid .ne. root) goto 900

       mflops = 0.0d0
       if( tmax .ne. 0. ) then
         do zone = 1, num_zones
           n3 = dble(nx(zone))*ny(zone)*nz(zone)
           navg = (nx(zone) + ny(zone) + nz(zone))/3.0
           nsur = (nx(zone)*ny(zone) + nx(zone)*nz(zone) +
     >             ny(zone)*nz(zone))/3.0
           mflops = mflops + 1.0d-6*float(niter) *
     >      (3478.8d0 * n3 - 17655.7d0 * nsur + 28023.7d0 * navg)
     >      / tmax
         end do
       endif

       call print_results('BT-MZ', class, gx_size, gy_size, gz_size, 
     >                    niter, tmax, mflops, num_procs, tot_threads,
     >                    '          floating point', 
     >                    verified, npbversion,compiletime, cs1, cs2, 
     >                    cs3, cs4, cs5, cs6, '(none)')

!---------------------------------------------------------------------
!      More timers
!---------------------------------------------------------------------
 900   if (.not.timeron) goto 999

       do i=1, t_last
          trecs(i) = timer_read(i)
       end do

       if (myid .gt. 0) then
          call mpi_recv(i, 1, MPI_INTEGER, 0, 1000, 
     >                  comm_setup, statuses, ierror)
          call mpi_send(trecs, t_last, dp_type, 0, 1001, 
     >                  comm_setup, ierror)
          goto 999
       endif

       ip = 0
       if (tmax .eq. 0.0) tmax = 1.0
 910   write(*,800) ip, proc_num_threads(ip+1)
 800   format(' Myid =',i5,'   num_threads =',i4/
     >        '  SECTION   Time (secs)')
       do i=1, t_last
          write(*,810) t_names(i), trecs(i), trecs(i)*100./tmax
          if (i.eq.t_rhs) then
             t = trecs(t_rhsx) + trecs(t_rhsy) + trecs(t_rhsz)
             write(*,820) 'sub-rhs', t, t*100./tmax
             t = trecs(t_rhs) - t
             write(*,820) 'rest-rhs', t, t*100./tmax
          elseif (i.eq.t_rdis2) then
             t = trecs(t_rdis1) + trecs(t_rdis2)
             write(*,820) 'exch_qbc', t, t*100./tmax
          endif
 810      format(2x,a8,':',f9.3,'  (',f6.2,'%)')
 820      format('    --> total ',a8,':',f9.3,'  (',f6.2,'%)')
       end do

       ip = ip + 1
       if (ip .lt. num_procs) then
          call mpi_send(myid, 1, MPI_INTEGER, ip, 1000, 
     >                  comm_setup, ierror)
          call mpi_recv(trecs, t_last, dp_type, ip, 1001, 
     >                  comm_setup, statuses, ierror)
          write(*,*)
          goto 910
       endif

 999   continue
       call mpi_barrier(MPI_COMM_WORLD, ierror)
       call mpi_finalize(ierror)

       end

