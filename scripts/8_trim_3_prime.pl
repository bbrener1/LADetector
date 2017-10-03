#!/usr/bin/perl
use strict;
use warnings;

#Randomization during seq prep: Inter-library ligation and sonication will generate DamID 
#primer sequences within reads and at end of reads (rare but possible).  Primer sequences 
#within reads are removed prior to first bowtie.  Primer at 5' or 3' end of reads may not 
#be detected pre-bowtie1 due to truncated sequences as a consequence of sonication.
#Prior to 2nd bowtie run, 13nts are removed from unmapped reads.  Some reads may still
#fail to map because of truncated primer sequences at the 3' end.
#This script removes 13 bases from the 3' end of reads that continue to be unmapped after
#both pre-processing steps prior to both bowtie runs.

open (FH, "$ARGV[0]") or die;

open (OUT, ">$ARGV[1]") or die;

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


	#if the line corresponds to nucleotide sequence, removes 13 nt from 3' end.  If read 
	#length after this trimming is > 24, report the read.  
	else {
                
		$i = substr($i, 0, -13);
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
