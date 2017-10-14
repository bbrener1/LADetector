#!/usr/bin/perl
use strict;
use warnings;

#This script counts the number of times a fragment has reads in it
#It takes the dpn delimited bins, and counts the number of times the
#bin has been registered in intersectBed
#input files are Dpn_tab.bed and the output to intersectBed
#run script like this perl script.pl input1(Dpn) input2 output.bed

open (FH1, "$ARGV[0]") or die;		#Dpn.bed
open (FH2, "$ARGV[1]") or die;		#output from bedtools intersect
open (OUT, ">$ARGV[2]") or die;		#output bed: chr start stop counts
my %Dpn;

#The following loop stores the Dpn bins into memory
while (my $i = <FH1>){
	chomp $i;
	my @temp = split("\t", $i);
	my $temp2 = join("\t", @temp[1,2]);
	$Dpn{$temp[0]}{$temp2}=0;
}

#The following loops counts the number of time a Dpn fragment has been reported in
#the bedtools intersect output file
while (my $i = <FH2>){
	chomp $i;
	my @temp1 = split("\t", $i);
	my $temp2 = join("\t", @temp1[7,8]);
	$Dpn{$temp1[6]}->{$temp2}++;
}


my @keys_chr = keys(%Dpn);
@keys_chr = sort @keys_chr;


#The following nested loops report the counts detected per Dpn bin in a bed format.
#If the bin has 0 counts, an arbitrary count of 1 is reported for convenience of
#normalization in subsequent scripts.
foreach my $i (@keys_chr){
	my @keys_coord = keys(%{$Dpn{$i}});
	@keys_coord = sort @keys_coord;

	foreach my $j (@keys_coord){
		if ($Dpn{$i}->{$j} == 0){
			print OUT "$i\t$j\t1\n";
		}
		else {
			print OUT "$i\t$j\t$Dpn{$i}->{$j}\n";
		}
	}
}
