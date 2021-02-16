#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
require "ACAI.pl";
require "ACAP.pl";
require "generateTestData.pl";
use Text::CSV qw(csv);
use Benchmark;
my $t0 = Benchmark->new;

my @k = (1..205);
my $n = 1023;
my $trialsPerK = 10000;
my @ACAresults;
my @headers = ("k","Sample Mean (Y)","Sample Variance (Y)","Sample Mean (2^Y)","Sample Variance (2^Y)");
my $thisk;
my $csv = Text::CSV->new ();
open my $fh, ">:encoding(utf8)", "results.csv" or die "results.csv: $!";
$csv->bind_columns (\(@headers));
$csv->say ($fh,\@headers);
for (@k)
{
    $thisk = $_;
    generateTestData($thisk,$n,$trialsPerK);
    @ACAresults = ACAI();
    unshift(@ACAresults,$thisk);
    #say("@ACAresults");
    $csv->say ($fh,\@ACAresults);
}
close($fh);

my $t1 = Benchmark->new;
my $td = timediff($t1, $t0);
print "the process took ",timestr($td);