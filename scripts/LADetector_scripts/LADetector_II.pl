#!/usr/bin/perl

open (FILE, "$ARGV[0]");
open (OUT, ">$ARGV[1]");
$line = <FILE>;
$line =~ s/\n//;
@array = split(/\t/, $line);
$lastchr = $array[1];
$laststart = $array[2];
$laststop = $array[3];
$lastnum = $array[5];
while ($line = <FILE>)
{
   $line =~ s/\n//;
   @array = split(/\t/, $line);
   if (samesign($lastnum, $array[5]) && $array[1] eq $lastchr)
   {
      $laststop = $array[3];
   } else
   {
      if (samesign($lastnum, 1))
      {
         $lastnum = 1;
      } else
      {
         $lastnum = -1;
      }
      print OUT ("$ARGV[0]\t$lastchr\t$laststart\t$laststop\t10\t$lastnum\n");
      $lastchr = $array[1];
      $laststart = $array[2];
      $laststop = $array[3];
      $lastnum = $array[5];
   }
}
if (samesign($lastnum, 1))
{
   $lastnum = 1;
} else
{
   $lastnum = -1;
}
print OUT ("$ARGV[0]\t$lastchr\t$laststart\t$laststop\t10\t$lastnum\n");

sub samesign
{
   my ($first, $last) = @_;
   if (abs($first + $last) == abs($first) + abs($last))
   {
      return 1;
   } else
   {
      return 0;
   }
}
