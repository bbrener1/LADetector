#!/usr/bin/env bash

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --partition=parallel
#SBATCH -t 500

source activate $3

local_absolute=$(readlink -f ./)

echo "Local address set as: $local_absolute"
# echo "$1"
# echo "$(find $(readlink -f $1) -iname *.gz)"
# echo "$2"
# ./scripts/fusor.sh $(find $(readlink -f $1) -iname *.gz) > $2

./scripts/pre-normalization-scoring.sh --input $(readlink -f $2) --scripts $local_absolute/scripts/ --build $local_absolute/data/GCA_000001405.15_GRCh38_no_alt_analysis_set --bins $local_absolute/data/DpnIIbins_hg38.bed.gz --slurm 40
