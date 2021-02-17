#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
require "ACAI.pl";
require "ACAP.pl";
require "generateTestData.pl";
use Text::CSV qw(csv);
use Time::HiRes qw(gettimeofday tv_interval);
my $t0 = [gettimeofday];

my @k = (205);
my $n = 1000000;
my $trialsPerK = 5;
my @ACAresults;
my @headers = ("k","Sample Mean (Y)","Sample Variance (Y)","Sample Mean (2^Y)","Sample Variance (2^Y)");
my $thisk;
my $csv = Text::CSV->new ();
#open my $fh, ">:encoding(utf8)", "results.csv" or die "results.csv: $!";
#$csv->bind_columns (\(@headers));
#$csv->say ($fh,\@headers);
for (@k)
{
    $thisk = $_;
    generateTestData($thisk,$n,$trialsPerK);
    @ACAresults = ACAP();
    unshift(@ACAresults,$thisk);
    #say("@ACAresults");
    $csv->say ($fh,\@ACAresults);
}
close($fh);

my $elapsed = tv_interval ($t0);
print "the whole process took $elapsed seconds.";