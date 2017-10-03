#!/usr/bin/perl
use strict;
use warnings;


#takes quality trimmed fastq files, remove contaminating sequences and regenerates fastq file as input to bowtie #1

my $infile = $ARGV[0];
open (FH, "$infile") or die;         #quality trimmed fastq

my $outfile = $ARGV[1];     #outputs fastq
open (OUT, ">$outfile") or die;



my $ID;
my $identifier;
my $line = 0;

while (my $i = <FH>){
	
	chomp ($i);
	
	if ($line == 4){				#4 lines per read for fastq, so if it gets to 5th line ie $line == 4, reinitialize to 1st line but next read
		$line = 0;
	
	}

	if($line == 0){					
		$ID = $i;					#stores identifer 
		$line++;
		next;

	}
	
	if(($line ==  2) || ($line == 3)){
		$line++;
        next;
    }

	
	elsif($line == 1){				#if the line corresponds to nucleotide sequence, search for DamID primer/adapter sequences (following 3 lines)
		
		$i =~ s/CTAATACGACTCACTATAGGGCAGCGTGGTCGCGGCCGAGGA/\//g;       #replaces adapter sequence by /
		$i =~ s/TCCTCGGCCGCGACCACGCTGCCCTATAGTGAGTCGTATTAG/\//g;	   #replaces adapter sequence by /
		$i =~ s/GATCCTCGGCCGCGACCGGTCGCGGCCGAGGATC/ /g;				   #replaces primer sequence by  space
				
		
		#ignore all reads that have adapter sequences:  ie adapter concatemers
		if ($i =~ /\//){					
			
			$line++;
			next;
				
		}

		#this will process all other reads.  Reads with no delimiters are unaffected and the original sequence will be reported (for read length > 25).
		#reads with spaces will be split into separate reads (as long as read length >25).  eg.   gaattccatg gtttaagc will be reported 2 reads: gaattccatg and gtttaagc	
		#but these 2 reads will not be reported since read length is less than 25.
		else {							   
			my @temp = split ('\s+',$i);
			my $count = 0;
			
			while ($temp[$count]){
				 
				if (length($temp[$count])<25){ 
					
					$count++;
					next;
					
				}
				
				else {
					
					print OUT "$ID _ $count\n$temp[$count]\n+\n";
					print OUT "~"x length($temp[$count]); print OUT "\n";
					$count++;
				
				}
			}
		
		}	
	}

	$line++;
}

close (OUT);
