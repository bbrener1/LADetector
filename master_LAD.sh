#!/usr/bin/env bash

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --partition=parallel
#SBATCH -t 500

source activate $3

# echo "$1"
# echo "$(find $(readlink -f $1) -iname *.gz)"
# echo "$2"
./scripts/fusor.sh $(find $(readlink -f $1) -iname *.gz) > $2

./scripts/pre-normalization-scoring.sh --input $(readlink -f $2) --scripts ./scripts/ --build ./data --bins ./data/DpnIIbins_hg38.bed.gz
