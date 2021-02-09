#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
require "ACA1.pl";
require "generateTestData.pl";
use Text::CSV qw(csv);
use Benchmark;
my $t0 = Benchmark->new;


my @k = (1..205);
my $n = 1023;
my @ACA1results;
my @headers = ("k","Sample Mean (Y)","Sample Variance (Y)","Sample Mean (2^Y)","Sample Variance (2^Y)","Sample Mean (4^Y)","Sample Variance (4^Y)");
my $thisk;
my $csv = Text::CSV->new ();
open my $fh, ">:encoding(utf8)", "results.csv" or die "results.csv: $!";
$csv->bind_columns (\(@headers));
$csv->say ($fh,\@headers);
for (@k)
{
    $thisk = $_;
    generateTestData($thisk,$n,10000);
    @ACA1results = ACA1();
    unshift(@ACA1results,$thisk);
    #say("@ACA1results");
    $csv->say ($fh,\@ACA1results);
}
close($fh);

my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the process took ",timestr($td);