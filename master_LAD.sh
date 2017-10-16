#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=22
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
  echo "Processing $p"
  i=$(basename $p)

  # echo "Fusing dam"
  # ./scripts/fusor.sh $(find $(readlink -f $p/Dam/) -iname *.gz) > $2$i.dam.fused.fastq;
  #
  # echo "Fusing done"
  #
  # ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2$i.dam.fused.fastq) --scripts $local_absolute/scripts/ --build $local_absolute/data/GCA_000001405.15_GRCh38_no_alt_analysis_set --bins $local_absolute/data/DpnIIbins_hg38.bed --slurm 22
  #
  # echo "Dam scoring complete"

  echo "Fusing lmnb"
  ./scripts/fusor.sh $(find $(readlink -f $p/LmnB/) -iname *.gz) > $2$i.lmnb.fused.fastq;

  echo "Fusing done"

  ./scripts/pre-normalization-scoring.sh --input $(readlink -f $2$i.lmnB.fused.fastq) --scripts $local_absolute/scripts/ --build $local_absolute/data/GCA_000001405.15_GRCh38_no_alt_analysis_set --bins $local_absolute/data/DpnIIbins_hg38.bed --slurm 22
  #
  # perl $local_absolute/scripts/Normalization.pl $2$i.dam.fused.preNormalization.score $2$i.lmnB.fused.preNormalization.score $2$i.dam.fused.mappedReadCounts $2$i.lmnb.fused.mappedReadCounts $2$i.normalized

done
