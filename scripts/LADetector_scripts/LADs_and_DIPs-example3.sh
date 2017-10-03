#!/bin/sh

#######################################################################################
#						TO DO before you run this script							  #
#							                         							      #
SCRIPTS=~/Documents/scripts/LADetector_scripts/LADs_and_DIPs.sh
GENOME=~/Documents/scripts/LADetector_scripts/mouse.mm9.genome 
UNALIGNABLE=~/Documents/scripts/LADetector_scripts/mm9.unalignable.txt
#Enter the path of your LADetector_folder within the parenthesis.        			  #
#P.S. remove the parenthesis after.                      	  						  #
#Enter the path to mm9.genome file - format:   chr    chrSize						  #
#######################################################################################

############################## Running the script #####################################
#								       		 									      #			
# .path_to_LADs_and_DIPs.sh path_to_normalized.bed min_DIP_size max_DIP_size	      #
#										   										      #
#                            OR if submitting to slurm					              #
#sbatch t hh:mm:ss LADs_and_DIPs.sh /path/to/normalized/bed min_DIP_size max_DIP_size #
#										     										  #
# For default LAD-detector_III settings, enter 0 and 0 for min_DIP_size and           #
# max_DIP_size, respectively													      #
#######################################################################################


DIRS=$(dirname "${SCRIPTS}")

#getting prefix for input filenames 
input=$1
prefix="${input%.*}"

#1. first, sort the normalized bed file by coordinates
sortBed -i $1>$prefix.sorted.bed

#2. remove unalignable bins from bed file and generate both a bedgraph removed of unalignable 
#bins and a bed file with unalignable regions to be used later
bedtools intersect -a $prefix.sorted.bed -b $UNALIGNABLE -v > $prefix.bedgraph

#3. LADetector I: Uses a circular binary segmentation algorithm from the DNAcopy 
#package by Olshen(2007) to identify domains
Rscript $DIRS/LADetector_I.R $prefix.bedgraph $prefix.seg

#4. LADetector II: Converting domains from LAD detector I into +/- associated bins.
perl $DIRS/LADetector_II.pl $prefix.seg $prefix.consolidated

#5. LADetector III: Identify intervals that correspond to LADs, interLADs or Dips.
perl $DIRS/LADetector_III.pl -j $2 -n $3 $prefix.consolidated $prefix.out $prefix.DIPs

#6. just in case, sort the unalignable regions(.repeats) output file by coordinates
sortBed -i $UNALIGNABLE >$unalignable.sorted

#8. complement unalignable regions (.repeats.sorted)
perl $DIRS/complement_intervals.pl $GENOME $unalignable.sorted $unalignable.complement

bedtools intersect -a $prefix.out -b $unalignable.complement -u> $prefix.LADs

