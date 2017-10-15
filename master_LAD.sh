#!/usr/bin/env bash

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --mem-per-cpu=5G
#SBATCH --partition=parallel
#SBATCH -t 500

source activate $3

local_absolute=$(readlink -f ./)

echo "Local address set as: $local_absolute"
echo "$1"
# echo "$(find $(readlink -f $1) -iname *.gz)"
echo "$2"

for p in $(cat $1);
do
  echo $(cat $1)
  echo $p
  i=$(basename $p)
  echo "$i"
  ./scripts/fusor.sh $2$i.dam.fused.fastq $(find $(readlink -f $i/Dam/) -iname *.gz);

  echo "I finished fusing, now I'm in master_LAD body!"

  # ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2$i.dam.fused.fastq) --scripts $local_absolute/scripts/ --build $local_absolute/data/GCA_000001405.15_GRCh38_no_alt_analysis_set --bins $local_absolute/data/DpnIIbins_hg38.bed --slurm 40
  #
  # ./scripts/fusor.sh $(find $(readlink -f $i/LmnB/) -iname *.gz) > $2$i.lmnb.fused.fastq;
  #
  # ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2$i.lmnB.fused.fastq) --scripts $local_absolute/scripts/ --build $local_absolute/data/GCA_000001405.15_GRCh38_no_alt_analysis_set --bins $local_absolute/data/DpnIIbins_hg38.bed --slurm 40

  # perl $local_absolute/scripts/Normalization.pl $2$i.dam.fused.preNormalization.score $2$i.lmnB.fused.preNormalization.score $2$i.dam.fused.mappedReadCounts $2$i.lmnb.fused.mappedReadCounts $2$i.normalized

done
