#!/bin/bash 
# waterfalls 0.0.1 
# works with standard vasp file structure
# requires bc

N_MAX=3 # maximum iteration steps
ETOL=0.005 # convergence tolerance in eV
VASP_CMD=~/install/vasp.5.4.4/build/std/vasp # vasp runtime
N_CPU=24 # for slurm 
VOL_THRES=1000 # skip the relaxation if the volume gets too large 

# vasp executable specific to the (slurm) batch system
function submit {
   srun -n $N_CPU $VASP_CMD
}

# read the relaxed energy (at 0 K) from OSZICAR
function read_e0 () {
  if [[ $1 == 'new' ]]; then
    echo $(grep E0 OSZICAR | tail -n 1 | awk '{printf "%.5f", $5}')
  else
    if [ -f OSZICAR.$1 ]; then
      echo $(grep E0 OSZICAR.$1 | tail -n 1 | awk '{printf "%.5f", $5}')
    else
      echo 0
    fi
  fi
}

# save the previous state
function save () {
  cp POSCAR POSCAR.$1
  cp OSZICAR OSZICAR.$1
  cp OUTCAR OUTCAR.$1
  cp vasprun.xml vasprun.xml.$1
}

# main
# sanity check
if [ -f .done ] || [ ! -f POSCAR ]; then exit 0; fi
if [ -f OUTCAR ]; then
  vol=`grep vol OUTCAR | tail -n 1 | awk '{print $5}'`
  vol=${vol%.*}
  if (( vol > $VOL_THRES )); then
    touch .vol_too_large
    exit 0
  fi
fi
#
last_n=$(for i in POSCAR*; do l=${i#*.}; done; echo $l| tail -n1)
if [[ $last_n = 'POSCAR' ]]; then
  [ -f CONTCAR ] && last_n=-1 || last_n=-2
fi
next_n=$((last_n+1))
if [[ $next_n == "-1" ]]; then
   submit
   last_n=-1; next_n=0
fi

# iteration block
n=0
while [[ $n < $N_MAX ]]; do
  if grep -q E0 OSZICAR; then 
    save $next_n
  else
    (( next_n-- ))
    (( last_n-- ))
  fi
  [ -f CONTCAR ] && cp CONTCAR POSCAR
  submit

  e0=$(read_e0 $next_n)
  e0_new=$(read_e0 new)
  if (( $(echo "$e0_new - $e0 > -$ETOL && $e0_new - $e0 < $ETOL" | bc -l) )); then
    touch .done
    exit 0
  else
    (( n++ ))
    last_n=$next_n
    (( next_n++ ))
  fi
done

exit 0
