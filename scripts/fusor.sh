#!/usr/bin/env bash

while [[ "$#" > 1 ]]; do
    zcat $1 | parallel --pipe -k;
    shift;
done
