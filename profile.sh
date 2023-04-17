#!/bin/bash   
#SBATCH --job-name=profile      
#SBATCH --nodes=4          
#SBATCH --partition=work  
#SBATCH --time=00:05:00
#SBATCH --output=%j.out              
#SBATCH --error=%j.err   

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/lib/intel64/libimf.so
export IPM_DIR=/jet/home/rliang1/gaojiali/software/hpcx-2.13.1/ompi/tests/ipm-2.0.6
export IPM_KEYFILE=$IPM_DIR/etc/ipm_key_mpi
#export LD_PRELOAD=/jet/home/rliang1/gaojiali/software/hpcx-2.13.1/ompi/tests/ipm-2.0.6/lib/libipmf.so
export IPM_REPORT=full
export IPM_LOG=full
export IPM_STATS=all
export IPM_LOGWRITER=serial
#export LD_PRELOAD=$IPM_DIR/lib/libipm.so

#export PROFILE_FLAGS="-x LD_PRELOAD=$IPM_DIR/lib/libipm.so:$IPM_DIR/lib/libipmf.so "
#export PROFILE_FLAGS="-x LD_PRELOAD=$IPM_DIR/lib/libipm.so:$IPM_DIR/lib/libipmf.so "
export KMP_AFFINITY=granularity=thread,compact
export OMP_PROC_BIND=spread
export OMP_PLACES=cores

module load phdf5/1.10.7-openmpi4.0.2-intel20.4
module use /jet/home/rliang1/gaojiali/software/hpcx-2.13.1/modulefiles
module load hpcx
srun hostname -s | sort -n >slurm.hosts 

cd testsuite
POT3D_HOME=$PWD/..
TEST="small"
cp ${POT3D_HOME}/testsuite/${TEST}/input/* ${POT3D_HOME}/testsuite/${TEST}/run/
cd ${POT3D_HOME}/testsuite/${TEST}/run

mpirun  -n 512 -machinefile /ocean/projects/bio220064p/rliang1/gaojiali/ISC23/POT3D/slurm.hosts  ${POT3D_HOME}/bin/pot3d_hpcx > pot3d.log

echo "Done!"
# Get runtime:
runtime=($(tail -n 5 timing.out | head -n 1))
echo "Wall clock time: ${runtime[6]} seconds"
echo " "

# Validate run:
${POT3D_HOME}/scripts/pot3d_validation.sh pot3d.out ${POT3D_HOME}/testsuite/${TEST}/validation/pot3d.out
