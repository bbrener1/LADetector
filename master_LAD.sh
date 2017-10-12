#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --partition=parallel
#SBATCH -t 500

module unload git
module load anaconda-python
module load samtools
# source activate reddy_cancer

srun ./scripts/fusor.sh $(ls $1 | grep .gz) > $2
echo "$1"
echo "$(ls $1 | grep .gz)"
echo "$2"
# sbatch ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2) --scripts ./scripts/ --build ./data --bins ./data/DpnIIbins_hg38.bed.gz --slurm 1
