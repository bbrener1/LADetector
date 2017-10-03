use strict;
use warnings;

#takes the unmapped file from 2nd bowtie run and looks for identifiers of unmapped reads.
#run like this: perl script_path bowtie2_unmapped_path output_identifiers_path

open (FH, "$ARGV[0]") or die;
open (OUT, ">$ARGV[1]") or die;

my $count = 0;


while (my $i = <FH>){
	chomp $i;
	if ($count ==4){
		$count = 0;
	}
	if ($count == 0){
		print OUT "$i\n";
		$count++;		
	}
	else {
		$count++;
	}

}

