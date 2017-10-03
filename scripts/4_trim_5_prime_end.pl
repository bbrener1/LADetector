#!/usr/bin/perl
use strict;
use warnings;

#Randomization during seq prep: Inter-library ligation and sonication will generate DamID 
#primer sequences within reads and at end of reads (rare but possible).  Primer sequences 
#within reads are removed prior to first bowtie.  Primer at 5' or 3' end of reads may not 
#be detected pre-bowtie1 due to truncated sequences as a consequence of sonication.
#This script removes 13 bases from the 5' end of unmapped reads from the 1st bowtie run, 
#attempting to retrieve mappable reads that are otherwise removed from analysis.
#Takes unmapped reads from 1st bowtie run [fastq] and remove 13 bases from 5' end of reads

open (FH, "$ARGV[0]") or die;      #input unmapped fastq

open (OUT, ">$ARGV[1]") or die;    #output same unmapped reads removed of 13nt from 5' end

my $ID;
my $count = 0;

while (my $i = <FH>){
	chomp ($i);
	my $j = $i;

	if ($count == 4){
		$count = 0;
	}
	
	if ($count == 0){
		$ID = $i;
		$count++;
	}

	elsif ($count == 2 || $count == 3){
		
		$count++;
	}


	#if the line corresponds to nucleotide sequence, removes 13 nt from 5' end.  If read 
	#length after this trimming is > 24, report the read.  
	else {
                
		$i = substr($i, 13);
		if(length($i)>24){
			print OUT "$ID\n";
			print OUT "$i\n";
			print OUT "+\n";
			print OUT "~" x length($i);
			print OUT "\n";
		}
		$count++;
	
	}
	
}
