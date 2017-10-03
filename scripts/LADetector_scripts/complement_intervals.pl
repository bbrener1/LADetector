open (GENOME, "$ARGV[0]") or die;
open (BED, "$ARGV[1]") or die;
open (OUT, ">$ARGV[2]") or die;

my %sizes;

my %chr;

#this stores all information about chromosome size.  chr number as keys and 
#size in values of the hash %sizes
while (my $i = <GENOME>){
	chomp $i;
	my @temp = split('\s+', $i);
	
	$sizes{$temp[0]}= $temp[1];
}



my $j = <BED>;
chomp $j;
my @temp = split('\s+', $j);
my $lastStart = $temp[1];
my $lastStop = $temp[2];
my $lastChr= $temp[0];
$chr{$lastChr}=1;

my $j = <BED>;
chomp $j;
my @temp = split('\s+', $j);
my $nextChr=$temp[0]; 
my $nextStart=$temp[1]; 
my $nextStop=$temp[2];

if ($lastStart > 0){
		print OUT "$lastChr\t0\t$lastStart\n";

	}
else {
	print OUT "$lastChr\t$lastStop\t$nextStart\n";
}

$lastStart = $nextStart;
$lastStop = $nextStop;
$lastChr = $nextChr;

print "1\n";

while ($j=<BED>){
	chomp $j;
	print "1\n";
	my @temp = split('\s+', $j);
	
	$nextChr = $temp[0];
	$nextStart = $temp[1];
	$nextStop = $temp[2];

	
	if ($lastChr ne $nextChr){
		$chr{$lastChr}=$nextChr;
	
		if($lastStop<$sizes{$lastChr}){
			print OUT "$lastChr\t$lastStop\t$sizes{$lastChr}\n";
		}
		
		if ($nextStart > 0){
			print OUT "$nextChr\t0\t$nextStart\n";

		}

	}
	
	else {
		print OUT "$lastChr\t$lastStop\t$nextStart\n";
	}
	
	$lastStart = $nextStart;
	$lastStop = $nextStop;
	$lastChr = $nextChr;
	
}
		
if($lastStop<$sizes{$lastChr}){
		print OUT "$lastChr\t$lastStop\t$sizes{$lastChr}\n";
}	

	
#my @chrAvail = keys(%sizes);

#foreach my $k (@chrAvail){
#	if($chr{$k}==undef){
#		print "$k\t0\t$sizes{$k}\n";
#	}
#}



	
	
	
	

