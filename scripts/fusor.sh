#!/usr/bin/env bash

while [[ "$#" > 0 ]]; do
    echo "Starting gzip fusion"
    zcat $1;
    shift;
done
wait
echo "Finished fusing gzipped files"
