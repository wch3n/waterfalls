#!/bin/bash

if [ -n "$1" ]
then
    JOB=$1
    if [ ! -d $JOB ]; then
         echo "No $JOB found. Exiting."
         exit 1
    elif grep -q $(pwd -P)/$JOB <(listjob.sh); then
        echo "$JOB already in queue. Aborting."
        exit 1
    fi
else
    echo "Job directory missing. Exiting."
    exit 1
fi

cd $PWD/$JOB

cat > vasp.sh <<END
#!/bin/bash

#SBATCH --job-name $JOB
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 24
#SBATCH --partition Zoe
#SBATCH --mem-per-cpu 1500mb
#SBATCH --qos zoe
#SBATCH --output ${JOB}.log
#SBATCH --error ${JOB}.log
#SBATCH --time 48:00:00
#SBATCH --constraint SkyLake

ulimit -s unlimited
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi.so
module load intel
~/bin/waterfalls.sh

END

sbatch vasp.sh
