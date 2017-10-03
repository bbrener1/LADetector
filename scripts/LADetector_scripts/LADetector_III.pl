#!/usr/bin/perl

#defining dips and lads
#dips are defined based on 2 parameters:  window (lower limit) and max (upper limit)
#if the negative interval exceeds the max size, it is defined as an inter-LAD ie non-LAD
#if the negative interval is a dip or < window, the 2 flanking lads are stitched together.

#########################################################################################
# options:																				#
# -j $window																			#
# -n $max																				#
# -h boolean condition for using help display										    #
# -l boolean for using arguments -j and -n											    #
#########################################################################################

use strict;
use warnings;
use Getopt::Std;


my %options=();
getopts("hj:ln:s:", \%options);

#options:
# -j $window
# -n $max
# -h boolean condition for using ij and -n else use default

if ($options{h}){
	print "----------------help menu-------------------\n";
	print "-j\tINT\tdefines minimum window size to define a dip.  Default: 2000\n";
	print "-n\tINT\tdefines max window size to define a dip. Default: 7000\n";
	print "-h\t\tprints the help menu\n";
	
	exit;
}

my $window;
my $max;

if ($options{j}){
	$window = $options{j};
}
else {
	$window = 2000;
}

if ($options{n}){
	$max = $options{n};
}
else {
	$max = 7000;
}

print "$window:$max\n";


open (FH, "$ARGV[0]") or die ("need consolidated seg file");
open (LAD, ">$ARGV[1]") or die;
open (DIP, ">$ARGV[2]") or die;

my $lastChr=0;
my $lastPosStop = 0;
my $lastPosStart = 0;
my $lastDipStop = 0;
my $lastDipStart = 0;

my $flag=1;


while (my $i = <FH>){
	chomp $i;
	my @array = split('\s+', $i);

	
	if ($array[1] ne $lastChr){
		if (!$flag){
			print LAD "$lastChr\t$lastPosStart\t$lastPosStop\t1\n";      ##########
			
		}
		$flag = 0;
		#start new chr
		$lastChr = $array[1];
		if ($array[5]>0){
			$lastPosStop = $array[3];
			$lastPosStart = $array[2];
		}
		else{
			$flag = 1;
		}
	}	

	else{								#same chr
		if ($array[5]>0){
			$lastPosStop = $array[3];
			if ($flag == 1){		
				$lastPosStart = $array[2];
				$flag = 0;
			}
		}
		else {
				my @output = dipOrInterLAD($array[2], $array[3], $window, $max);
				
				if ($output[0] == 0 && $output[1] != 0){
					$lastPosStop = $output[1];
				}
				elsif ($output[0] == 1){
					$lastPosStop = $output[1];
					print DIP "$array[1]\t$array[2]\t$array[3]\t1\n";
				}
				elsif ($output[0] == 0 && $output[1] == 0){
					$flag = 1;
					print LAD "$lastChr\t$lastPosStart\t$lastPosStop\t1\n";     ##########
				}		
		}
	}
	

}

#writing last element of file
if (!$flag){
	print LAD "$lastChr\t$lastPosStart\t$lastPosStop\t1\n";  
}



	
close (FH);
close (LAD);
close (DIP);			
			
sub dipOrInterLAD {

	my ($start, $stop, $window, $max) = @_;
	
	if(($stop - $start) <= $window){
		return (0, $stop);				#random noise - stitch across
	}
				
	elsif(($stop - $start) >$window && ($stop - $start)<$max){
		return (1, $stop);				#dip within a LAD - stitch across to signify it's a feature in lad
	}
			
			
	else{
		return (0,0);					#inter-LAD
	}
		
}

