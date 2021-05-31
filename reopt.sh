#!/bin/bash

workdir=$1
tmpfile=/tmp/$RANDOM

if [ ! -d $1 ]; then
   echo "$1 not found. exiting."
   exit 1
fi

for i in $workdir/OSZICAR.*; do printf ${i##*.}; grep E0 $i | tail -n 1; done > $tmpfile
nmax=$(sort -n -k 4 $tmpfile | head -n 1 | awk '{print $1}')
if [ -f $workdir/CHGCAR.$nmax ]; then 
  cp -f $workdir/CHGCAR.$nmax $workdir/CHGCAR
  echo "CHGCAR.$nmax ready"
else
  echo "CHGCAR not found"
  exit 1
fi
if [ -f $workdir/POSCAR.$((nmax+1)) ]; then 
  cp -f $workdir/POSCAR.$((nmax+1)) $workdir/CONTCAR
  echo "POSCAR.$((nmax+1)) ready"
else
  echo "POSCAR.$((nmax+1)) not found"
  exit 1
fi

if grep -q ICHARG $workdir/INCAR; then
  sed -i 's/ICHARG.*/ICHARG = 1/g' $workdir/INCAR
else
  echo "ICHARG = 1" >> $workdir/INCAR
  echo "ICHARG set"
fi

rm -f $tmpfile
touch $workdir/.reopt_done
