#!/usr/bin/env bash

echo "Starting fusion"
echo $0
echo "" > $1
shift
while [[ "$#" > 0 ]]; do
    echo "Fusing $1"
    zcat $1 >> $1;
    shift;
done
echo "Finished fusion"
