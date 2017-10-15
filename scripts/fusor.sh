#!/usr/bin/env bash

while [[ "$#" > 0 ]]; do
    zcat $1;
    shift;
done
