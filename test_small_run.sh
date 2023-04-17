#!/bin/bash   
#SBATCH --job-name=pot3d           
#SBATCH --nodes=4           
#SBATCH --partition=work
#SBATCH --time=01:00:00
#SBATCH --output=%j.out              
#SBATCH --error=%j.err   

#module load intelmpi-2021.7.0
#module load hdf5/1.10.7-impi-intel
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/apps/SPACK/0.19.0/opt/linux-almalinux8-icelake/intel-2021.7.0/hdf5-1.12.2-l7wmsy76ansuprtkjfj6nsvfbd2owmkc/lib/libhdf5_fortran.so.200 
cd testsuite

POT3D_HOME=$PWD/..
TEST="small"

cp ${POT3D_HOME}/testsuite/${TEST}/input/* ${POT3D_HOME}/testsuite/${TEST}/run/
cd ${POT3D_HOME}/testsuite/${TEST}/run

echo "Running POT3D with $NP MPI rank..."
mpirun -np  288 -ppn 72 $NP ${POT3D_HOME}/bin/pot3d_impi > pot3d.log
echo "Done!"

# Get runtime:
runtime=($(tail -n 5 timing.out | head -n 1))
echo "Wall clock time: ${runtime[6]} seconds"
echo " "

# Validate run:
${POT3D_HOME}/scripts/pot3d_validation.sh pot3d.out ${POT3D_HOME}/testsuite/${TEST}/validation/pot3d.out
