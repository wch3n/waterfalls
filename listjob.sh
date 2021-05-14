#!/bin/bash

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
    printf "%-60s %8s r \n" $workdir $pid
done

for pid in `squeue -l -u $user | grep $user | grep PEND | awk '{print $1}' `; do
    workdir=`scontrol show job $pid | grep WorkDir | awk -F= '{print $2}'`
    printf "%-60s %8s p \n" $workdir $pid 
done
