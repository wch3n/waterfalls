#!/bin/bash
# job query script for SLURM scheduler
# needed for submit.sh to avoid duplicate job submission

is_running(){
  any=$(find $1 -cmin -60 | egrep '.*')
  if [[ ! -z "$any" ]]; then
    echo [OK]
  else
    echo [ZOMBIE]
  fi
}

user=wchen

for pid in `squeue -l -u $user | grep $user | grep RUNNING | awk '{print $1}' `; do
    workdir=`scontrol show job $pid | grep WorkDir | awk -F= '{print $2}'`
    err=$(is_running $workdir)
    printf "%-60s %8s %10s \n" $workdir $pid $err
done

for pid in `squeue -l -u $user | grep $user | grep PEND | awk '{print $1}' `; do
    workdir=`scontrol show job $pid | grep WorkDir | awk -F= '{print $2}'`
    err="[PEND]"
    printf "%-60s %8s %10s \n" $workdir $pid $err
done
