#!/usr/bin/perl

#normalization script.  Takes lmnb1 scores - column 4 of LmnB1 output from last script, 
#normalizing it by read number and divides it by column 4 of Dam output that has been 
#normalized by read number for each bin.
#It yields log2 ratios for each bin

#Use it like this:  perl script_path Dam-Bed LmnB1-Bed Dam_count_path LmnB_count_path output_path
#5bed files of of the format chr start stop counts
 

use warnings;
use strict;

my $infile1 = $ARGV[0];  #Dam Bed
my $infile2 = $ARGV[1];  #LmnB1 Bed

my $DamInfile = $ARGV[2];    #Dam Count
my $LmnBInfile = $ARGV[3];   #LmnB1 Count

my $outfile = $ARGV[4]; #output path

open (IN_Dam, $infile1) or die;
open (IN_LB, $infile2) or die;

open (OUT, '>', $outfile) or die;
open (DAM, $DamInfile) or die;
open (LB, $LmnBInfile) or die;

my @temp = split ('\s+',<DAM>);
my $x = $temp[0];                    #stores number of Dam Reads

@temp = split ('\s+',<LB>);
my $y = $temp[0];					#stores number of Dam-LmnB1 Reads


#The following loops performs the normalization:  (LmnB1/LmnB1 read count)/(Dam/Dam read count)
while (my $i = <IN_Dam>){
	chomp $i;
	
	my @temp_Dam = split('\s+', $i);
	
	my $j = <IN_LB>;
	chomp $j;
	
	my @temp_LB = split('\s+', $j);
	
	my $score = log(($temp_LB[3]/$y)/($temp_Dam[3]/$x))/log(2);
	print OUT "$temp_Dam[0]\t$temp_Dam[1]\t$temp_Dam[2]\t$score\n";
}


