#!/usr/bin/perl
use strict;
use warnings;

#run script like this perl script.pl infile.fastq outfile.fastq

#stores symbols and their respective scores
sub getScoreDict {
	my %scores = ();
	$scores{"!"} = 0;
	$scores{"\""} = 1;
	$scores{"#"} = 2;
	$scores{"\$"} = 3;
	$scores{"%"} = 4;
	$scores{"&"} = 5;
	$scores{"'"} = 6;
	$scores{"("} = 7;
	$scores{")"} = 8;
	$scores{"*"} = 9;
	$scores{"+"} = 10;
	$scores{","} = 11;
	$scores{"-"} = 12;
	$scores{"."} = 13;
	$scores{"/"} = 14;
	$scores{"0"} = 15;
	$scores{"1"} = 16;
	$scores{"2"} = 17;
	$scores{"3"} = 18;
	$scores{"4"} = 19;
	$scores{"5"} = 20;
	$scores{"6"} = 21;
	$scores{"7"} = 22;
	$scores{"8"} = 23;
	$scores{"9"} = 24;
	$scores{":"} = 25;
	$scores{";"} = 26;
	$scores{"<"} = 27;
	$scores{"="} = 28;
	$scores{">"} = 29;
	$scores{"?"} = 30;
	$scores{"@"} = 31;
	$scores{"A"} = 32;
	$scores{"B"} = 33;
	$scores{"C"} = 34;
	$scores{"D"} = 35;
	$scores{"E"} = 36;
	$scores{"F"} = 37;
	$scores{"G"} = 38;
	$scores{"H"} = 39;
	$scores{"I"} = 40;
	$scores{"J"} = 41;
	$scores{"K"} = 42;
	$scores{"L"} = 43;
	$scores{"M"} = 44;
	$scores{"N"} = 45;
	$scores{"O"} = 46;
	$scores{"P"} = 47;
	$scores{"Q"} = 48;
	$scores{"R"} = 49;
	$scores{"S"} = 50;
	$scores{"T"} = 51;
	$scores{"U"} = 52;
	$scores{"V"} = 53;
	$scores{"W"} = 54;
	$scores{"X"} = 55;
	$scores{"Y"} = 56;
	$scores{"Z"} = 57;
	$scores{"["} = 58;
	$scores{"\\"} = 59;
	$scores{"]"} = 60;
	$scores{"^"} = 61;
	$scores{"_"} = 62;
	$scores{"`"} = 63;
	$scores{"a"} = 64;
	$scores{"b"} = 65;
	$scores{"c"} = 66;
	$scores{"d"} = 67;
	$scores{"e"} = 68;
	$scores{"f"} = 69;
	$scores{"g"} = 70;
	$scores{"h"} = 71;
	$scores{"i"} = 72;
	$scores{"j"} = 73;
	$scores{"k"} = 74;
	$scores{"l"} = 75;
	$scores{"m"} = 76;
	$scores{"n"} = 77;
	$scores{"o"} = 78;
	$scores{"p"} = 79;
	$scores{"q"} = 80;
	$scores{"r"} = 81;
	$scores{"s"} = 82;
	$scores{"t"} = 83;
	$scores{"u"} = 84;
	$scores{"v"} = 85;
	$scores{"w"} = 86;
	$scores{"x"} = 87;
	$scores{"y"} = 88;
	$scores{"z"} = 89;
	$scores{"{"} = 90;
	$scores{"|"} = 91;
	$scores{"}"} = 92;
	$scores{"~"} = 93;

return \%scores;
}


#the following subroutine does the quality trimming
sub qualTrim {

	#get reads identifier, sequence and quality as input
	my $ID = $_[0];
	my $read = $_[1];
	my $quals = $_[2];
	
	#get reference to the dictionary phred scores
	my %scoreList = %{$_[3]};
	
	my @read_seq_temp = split('',$read);
	my @quals_temp = split('', $quals);
	
	
	my $count = 0;
	my $mean_score = 0;
	my @flag;   #this stores how many times mean is <30
	
	#trim from 5' 1st
	while (defined($quals_temp[$count + 2]) && $mean_score < 30){
		$mean_score = ($scoreList{$quals_temp[$count]} +  $scoreList{$quals_temp[$count+1]} + $scoreList{$quals_temp[$count+2]})/3;
		if ($mean_score < 30){
			push(@flag, $count);
		}
		$count++;
	}
	foreach my $k (@flag){
	
		#remove number of 5' bases that resulted in a mean score <30
		my $first_read = shift(@read_seq_temp);
		
		#remove number of 5' scores that resulted in a mean score <30
		my $first_qual = shift(@quals_temp);
	}
	
	#trim from 3' end
	$mean_score = 0;
	$count = scalar(@read_seq_temp)-1;
	@flag = ();  #empties it since used above
	while ($count >= 2 && $mean_score < 30){
		$mean_score = ($scoreList{$quals_temp[$count]} +  $scoreList{$quals_temp[$count-1]} + $scoreList{$quals_temp[$count-2]})/3;
		if ($mean_score < 30){
			push(@flag, $count);		
		}
		$count--;
	}
	foreach my $k (@flag){
		
		#remove number of 3' bases that resulted in a mean score <30
		pop(@read_seq_temp);
		
		#remove number of 3' scores that resulted in a mean score <30
		pop(@quals_temp);
	}
	
	#need to get rid of seq with 2 nts left since the above loops dont look at remaining 2 elements
	if (scalar(@quals_temp)<3){
		return;
	}
	
	#generate trimmed reads and quals
	$quals = join('', @quals_temp);
	$read = join('', @read_seq_temp);
	
	print OUT "$ID\n$read\n+\n$quals\n";
}

	
#main script
my $infile = $ARGV[0];     #get input untrimmed fastq
my $outfile = $ARGV[1];     #outputs trimmed fastq


open(IN, $infile) or die;
open (OUT, ">", $outfile) or die;

my %seq;
my $ID;
my $read;
my $quals;
my %score_;

#load quality scores
%score_ = %{getScoreDict()};
my $count = 0;

#load reads
while (my $i = <IN>){
	chomp $i;
	
	if ($count == 4){
		$count = 0;
	}

	if ($count == 0){
		$ID = $i;
	}
	elsif ($count == 1){
		$read = $i;
	}
	elsif ($count == 3){
		$quals = $i;
        qualTrim($ID, $read, $quals, \%score_);		#passes the arguments: identifier, read, quality and the reference to the ScoreDict hash
	}	 
	$count++;	
}





	

