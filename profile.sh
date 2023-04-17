#!/bin/bash   
#SBATCH --job-name=profile         
#SBATCH --nodes=4           
#SBATCH --partition=work
#SBATCH --time=01:00:00
#SBATCH --output=%j.out              
#SBATCH --error=%j.err   
   
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/apps/SPACK/0.19.0/opt/linux-almalinux8-icelake/intel-2021.7.0/hdf5-1.12.2-l7wmsy76ansuprtkjfj6nsvfbd2owmkc/lib

export IPM_DIR=/apps/hpcx/2.13.1-gcc-inbox/ompi/tests/ipm-2.0.6
export IPM_KEYFILE=$IPM_DIR/etc/ipm_key_mpi
export IPM_REPORT=full
export IPM_LOG=full
export IPM_STATS=all
export IPM_LOGWRITER=serial
export LD_PRELOAD=$IPM_DIR/lib/libipm.so
cd testsuite

POT3D_HOME=$PWD/..
TEST="small"

cp ${POT3D_HOME}/testsuite/${TEST}/input/* ${POT3D_HOME}/testsuite/${TEST}/run/
cd ${POT3D_HOME}/testsuite/${TEST}/run

echo "Running POT3D with $NP MPI rank..."
mpirun -np 288 -ppn 72 -x LD_PRELOAD=$IPM_DIR/lib/libipm.so ${POT3D_HOME}/bin/pot3d_impi > pot3d.log
echo "Done!"

# Get runtime:
runtime=($(tail -n 5 timing.out | head -n 1))
echo "Wall clock time: ${runtime[6]} seconds"
echo " "

# Validate run:
${POT3D_HOME}/scripts/pot3d_validation.sh pot3d.out ${POT3D_HOME}/testsuite/${TEST}/validation/pot3d.out
