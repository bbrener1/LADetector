#!/bin/sh

echo "Starting pre-normalization scoring:"

input="none"
scripts=./
build=../data
bins=../data/DpnIIbins_hg38.bed.gz
slurm=0


while [[ "$#" > 1 ]]; do case $1 in
		--scripts) scripts="$2";;
		--build) build="$2";;
		--bins) bins="$2";;
		--slurm) slurm="$2";;
		--input) input="$2";;
		*) break;;
	esac; shift; shift
done

if [ "$input" = "none" ]
	then
		echo "The --input option is mandatory! Specify input file"
		exit 137
fi

#getting prefix for input filenames
prefix="${input%.*}"
echo "Prefix set as: $prefix"
echo "Input set as: $input"

echo "$scripts" > "$prefix.local_addresses.txt"
echo "$build" >> "$prefix.local_addresses.txt"
echo "$bins" >> "$prefix.local_addresses.txt"

# dirs=$(dirname "${scripts}")
dirs="$scripts"
echo "$dirs" >> "$prefix.local_addresses.txt"


# if [ $slurm ]      #this will be true (on slurm) if the user enters 1 after the input file path.
# then
# 	module load bowtie
# 	module load samtools
# 	module load bedtools
# 	module load perl
# fi

head $input

echo "Trimming, step 1 (quality)"
# 1.  quality trim
perl $dirs/1_fastq_quality_trimmer.pl $input $prefix.qualitytrimmed

echo "Removing internal dsAdr, step 2"
# 2. remove internal dsAdr
perl $dirs/2_remove_internal_adaptors.pl $prefix.qualitytrimmed $prefix.bowtie1Input

echo "First alignment, step 3"
#3. 1st bowtie run
bowtie --threads $slurm --maxbts 125 -n 2 --max --strata --best $build -q $prefix.bowtie1Input --un $prefix.bowtie1_unmapped -S $prefix.bowtie1_mapped.sam

echo "Trim 5' ends of unaligned, step 4"
#4.  Trim 5' ends
perl $dirs/4_trim_5_prime_end.pl $prefix.bowtie1_unmapped $prefix.bowtie2Input

echo "Second alignment, step 5"
#5.  2nd bowtie run
bowtie --threads $slurm --maxbts 125 -n 2 --max --strata -e 70 -l 28 $build -q $prefix.bowtie2Input --un $prefix.bowtie2_unmapped  -S $prefix.bowtie2_mapped.sam

echo "Intermission: messing around to find reads that haven't aligned yet"
#6. find the identifiers of the unmapped reads
perl $dirs/6_rebuild_5prime_A.pl $prefix.bowtie2_unmapped $prefix.bowtie2_unmappedID

#7. find the untrimmed (5' untrimmed) reads corresponding to the IDs in step 6.
perl $dirs/7_rebuild_5prime_B.pl $prefix.bowtie2_unmappedID $prefix.bowtie1_unmapped $prefix.bowtie3Input_pre-trimmed

echo "Trim 3' ends of unaligned, step 5"
#8. trim 3' ends of reads from step 7.
perl $dirs/8_trim_3_prime.pl $prefix.bowtie3Input_pre-trimmed $prefix.bowtie3Input

echo "Third alignment, step 6"
#9.  3rd bowtie run
bowtie --threads $slurm --maxbts 125 -n 2 --max --strata -e 70 -l 28 $build -q $prefix.bowtie3Input --un $prefix.bowtie3_unmapped  -S $prefix.bowtie3_mapped.sam

echo "Sam => Bam, step 7"
#10. Convert all sam files (3 of them) to bams
samtools view -@ $slurm -bS $prefix.bowtie1_mapped.sam > $prefix.bowtie1_mapped.bam
samtools view -@ $slurm -bS $prefix.bowtie2_mapped.sam > $prefix.bowtie2_mapped.bam
samtools view -@ $slurm -bS $prefix.bowtie3_mapped.sam > $prefix.bowtie3_mapped.bam

echo "Merging Bams, step 8"
#11. Concatenate the bam files
samtools merge -@ $slurm -f $prefix.bowtie_mapped_all.bam $prefix.bowtie1_mapped.bam $prefix.bowtie2_mapped.bam $prefix.bowtie3_mapped.bam

echo "Generating Beds, step 9"
#12. convert the bam file to bed
bedtools bamtobed -i $prefix.bowtie_mapped_all.bam > $prefix.bowtie_mapped_all.bed

echo "Finding Dpn Bins, step 10"
#13. Perform bedtools intersect on Dpn bins.
bedtools intersect -wb -a $prefix.bowtie_mapped_all.bed -b $bins>$prefix.intersect.output

echo "Counting bin reads, step 11"
#14. Count number of reads that overlap each bin.
perl $dirs/14_counting_readNum_per_Bin.pl $bins $prefix.intersect.output $prefix.preNormalization.score

echo "Counting mapped reads, step 12"
#15. Count number of mapped reads
wc -l $prefix.bowtie_mapped_all.bed > $prefix.mappedReadCounts
