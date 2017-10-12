
#srun ./scripts/fusor.sh $1 > $2

srun ./scripts/pre-normalization-scoring.sh --input $(readlink -f $1) --scripts ./scripts/ --build ./data --bins ./data/DpnIIbins_hg38.bed.gz --slurm 1
