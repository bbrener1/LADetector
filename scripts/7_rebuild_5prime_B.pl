#use strict;
#use warnings;

#the previous script yield identifiers of reads that continue to be unmapped after 2nd 
#bowtie run.  This script requires the identifiers of those unmapped reads and the unmapped
#reads post 1st bowtie run and returns reads that remained unmapped from 1st and 2nd bowtie 
#runs WITHOUT the 5' removal of the 13 nt.


open (FH1, "$ARGV[0]") or die;    #stores IDs
open (FH2, "$ARGV[1]") or die;    #bowtie1 unmapped
open (OUT, ">$ARGV[2]") or die;	  #output reads with 5' ends un-trimmed

my %Wanted;

while (my $i = <FH1>){
	chomp $i;
	$Wanted{$i} = 1;
}

my $flag = 0;

while (my $j = <FH2>){
	chomp $j;
	
	#if a flag is raised, ie read matching unmapped identifier, report the read sequence
	#in fastq format and reset the flag back to zero
	if ($flag == 1){

		print OUT "$j\n";
		print OUT "+\n";
        print OUT "~" x length($j);
		print OUT "\n";
		$flag = 0;
	}
		
	#if the identifier of a read matches an unmapped identifier, 
	#raise a flag and print the identifier
	if ($Wanted{$j}){		
		
		print OUT "$j\n";
		$flag = 1;
	}
}
