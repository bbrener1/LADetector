#SBATCH --nodes=2
#SBATCH --ntasks-per-node=48
#SBATCH --partition=parallel
#SBATCH -t 500

module load anaconda-python
module load samtools
source activate reddy_cancer

srun ./scripts/fusor.sh $1 > $2

sbatch ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2) --scripts ./scripts/ --build ./data --bins ./data/DpnIIbins_hg38.bed.gz --slurm 1
