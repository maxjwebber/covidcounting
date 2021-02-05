#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
use POSIX;
use List::Util qw(sample);
use List::Util qw(any);

#0 is not infected, 1 is infected
my @testpool;
my $Y;
my $totalY;
my $EY;
my @subset;
my $subset_size;
my $subset_divisor;
my $m;
my $filename = "testdata.txt";

#MACA1 is:
# run ACA1 m times. let W be the average of those results (Y).
#(since we are reading the testdata until end of file, m will be determined after the fact.
#ACA1 is:
#Number the samples randomly 1 through n.
#(the order of the samples is already randomized when creating test data so we can arbitrarily number them by order of their indices)
#Choose independently subsets of size ⎾n/2⏋, ⎾n/4⏋, ⎾n/8⏋, ⎾n/16⏋, …, 1.
#Let Y = the number of subsets that test positive. Then EY ≈ log(k) where k is the number of infected individuals.

open(FH, '<', $filename) or die $!;

$m = 0;
$totalY = 0;
my $testpoolstring;
my $linelength;
while(<FH>){
    $linelength = ((length $_) - 1);
    $testpoolstring = substr($_, 0, $linelength);
    #for each line in the file, transform binary string to character list
    @testpool = split (//, $testpoolstring);
    #count the lines/number of test pools
    $m++;
    #init subset_divisor and Y
    $subset_divisor = 1;
    $Y = 0;
    do
    {
        #increase divisor by factor of 2, creating smaller and smaller subsets
        $subset_divisor*=2;
        $subset_size = ceil($linelength / $subset_divisor);
        @subset = sample $subset_size, @testpool;
        ##increase count of Y if someone in the subset is infected
        if (any {$_ == 1} @subset)
        {
            $Y++;
        }
    }while ($subset_size > 1);
    $totalY += $Y;
}
close(FH);
#calculate expected value (mean) of Y
$EY = $totalY / $m;
say "EY is $EY";