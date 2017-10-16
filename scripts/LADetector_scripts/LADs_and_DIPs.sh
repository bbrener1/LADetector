#!/bin/sh

# input="none"
# scripts=./LADetector_scripts/
# genome=../../data/human.hg38.genome
# unalignable=../../data/hg38.unalignable

max_DIP=7000
min_DIP=2000

while [[ "$#" > 1 ]]; do case $1 in
    --scripts) scripts="$2";;
    --genome) build="$2";;
		--unalignable) bins="$2";;
		--input) input="$2";;
    *) break;;
  esac; shift; shift
done

if [ "$input" = "none" ]
then
	echo "The --input option is mandatory! Specify input file"
	exit 2
fi

echo "$scripts"
echo $(readlink -f $genome)
echo $(readlink -f$unalignable)
echo "$input"

######################################
#TO DO before you run this script
# SCRIPTS=PATH_TO_DamID-LADetector_folder
#Enter the path of LADs_andDIPs.sh
# GENOME=PATH_TO_mm9.genome
#Enter the path to mm9.genome file - format:   chr    chrSize
# UNALIGNABLE=PATH_TO_mm9.unalignable.genome
#Enter the path to mm9.unalignable.genome file
######################################

######################################
#Running the script
#								       		 									      #
# .path_to_LADs_and_DIPs.sh path_to_normalized.bed min_DIP_size max_DIP_size	      #
#										   										      #
#                            OR if submitting to slurm					              #
#sbatch t hh:mm:ss LADs_and_DIPs.sh /path/to/normalized/bed min_DIP_size max_DIP_size #
#										     										  #
# For default LAD-detector_III settings, enter 0 and 0 for min_DIP_size and           #
# max_DIP_size, respectively													      #
#######################################################################################


# dirs=$(dirname "${scripts}")

#getting prefix for input filenames
prefix="${input%.*}"

#module load bedtools
#module load R

#1. first, sort the normalized bed file by coordinates
sortBed -i $1>$prefix.sorted.bed

#2. remove unalignable bins from bed file and generate both a bedgraph removed of unalignable
#bins and a bed file with unalignable regions to be used later
bedtools intersect -a $prefix.sorted.bed -b $unalignable -v > $prefix.bedgraph

#3. LADetector I: Uses a circular binary segmentation algorithm from the DNAcopy
#package by Olshen(2007) to identify domains
Rscript $scripts/LADetector_I.R $prefix.bedgraph $prefix.seg

#4. LADetector II: Converting domains from LAD detector I into +/- associated bins.
perl $scripts/LADetector_II.pl $prefix.seg $prefix.consolidated

#5. LADetector III: Identify intervals that correspond to LADs, interLADs or Dips.
perl $scripts/LADetector_III.pl -j $max_DIP -n $min_DIP $prefix.consolidated $prefix.out $prefix.DIPs

#6. just in case, sort the unalignable regions(.repeats) output file by coordinates
sortBed -i $unalignable >$unalignable.sorted

#8. complement unalignable regions (.repeats.sorted)
perl $scripts/complement_intervals.pl $genome $unalignable.sorted $unalignable.complement

bedtools intersect -a $prefix.out -b $unalignable.complement -u> $prefix.LADs

echo "Done"
