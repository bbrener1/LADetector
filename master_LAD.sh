
#srun ./scripts/fusor.sh $1 > $2

srun ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2) --scripts ./scripts/ --build ./data --bins ./data/DpnIIbins_hg38.bed.gz --slurm 1
