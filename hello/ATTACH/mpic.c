// --- CSCS (Swiss National Supercomputing Center) ---
// --- $HeadURL: svn+ssh://jgp@scm.hpcforge.org/var/lib/gforge/chroot/scmrepos/svn/codes/trunk/2013/debug/mpicuda2/mpic.c $
// --- $Revision: 223 $
// --- $Date: 2013-10-25 16:31:42 +0200 (Fri, 25 Oct 2013) $
// --- $LastChangedDate: 2013-10-25 16:31:42 +0200 (Fri, 25 Oct 2013) $
// --- $Author: jgp $
// --- $LastChangedBy: jgp $
// --- svn propset svn:keywords "HeadURL Revision Date LastChangedDate Author LastChangedBy" myfile
// --- svn propedit svn:keywords myfile
// --- CSCS (Swiss National Supercomputing Center) ---


#include <stdio.h>
#include <mpi.h>
#include <unistd.h>












int main(int argc, char *argv[])
{
  int rank, size, namelen;
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  char gpu_str[256] = "";
  MPI_Init (&argc, &argv);
  MPI_Comm_rank (MPI_COMM_WORLD, &rank);  
  MPI_Comm_size (MPI_COMM_WORLD, &size);  
  MPI_Get_processor_name(processor_name, &namelen);




#ifdef _ATTACH
  int n=0;   
  FILE *fp;
// ATTACH debugger to RUNNING JOB
// INFINITE LOOP => echo 0 > go
//       TO STOP => echo 9 > go
if ( rank == 0 ) {
        while (n != 57) { 
                fp = fopen("go", "r");

                if (fp == NULL ) { /* Could not open file */
                        printf("Error opening %s\n", "go"); return 1;
                } else {
                        printf("Opening %s OK\n", "go");
                }

                n=fgetc(fp);
                fclose(fp);
                printf("n=%d \n",n);
                sleep(3);
        }
}
#endif

  MPI_Finalize();

  return 0;
}
