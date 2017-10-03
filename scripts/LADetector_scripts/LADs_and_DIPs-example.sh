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

#module load bedtools
#module load R

#6. just in case, sort the unalignable regions(.repeats) output file by coordinates
sortBed -i $UNALIGNABLE >$unalignable.sorted

#8. complement unalignable regions (.repeats.sorted)
perl $DIRS/complement_intervals.pl $GENOME $unalignable.sorted $unalignable.complement

bedtools intersect -a $1 -b $unalignable.complement > $prefix.LADs


