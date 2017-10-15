#!/usr/bin/env bash

echo "Starting fusion"
for i in $(seq 1 $#);
do
  echo $i
done
echo "" > $1
target=$1
shift
while [[ "$#" > 0 ]]; do
    echo "Fusing $1"
    zcat $1 >> $target;
    ls -lh $target
    shift;
done
echo "Finished fusion"
