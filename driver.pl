#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
require "ACAI.pl";
require "ACAP.pl";
require "generateTestData.pl";
use Text::CSV qw(csv);
use Statistics::Regression;

if ($#ARGV != 4)
{
    die 'must supply all params. driver.pl [number of subjects] [lowest k] [highest k] [trials per each k]';
}

my $n = $ARGV[0];
if ($ARGV[1]!=0)
{
    say "use of lowest # infected greater than 0 is not advised; may skew linear regression."
}
my @k = ($ARGV[1]..$ARGV[2]);
my $trialsPerK = $ARGV[3];
my @ACAIresults;
my @ACAPresults;
my @headers = ("k","Sample Mean (Y)","Sample Variance (Y)","Sample Mean (2^Y)","Sample Variance (2^Y)");
my $thisk;
my $csv = Text::CSV->new ();
open my $fhP, ">:encoding(utf8)", "ACAP_results.csv" or die "ACAP_results.csv: $!";
open my $fhI, ">:encoding(utf8)", "ACAI_results.csv" or die "ACAI_results.csv: $!";
$csv->bind_columns (\(@headers));
$csv->say ($fhP,\@headers);
$csv->say ($fhI,\@headers);
my $regP = Statistics::Regression->new("ACAP",["Intercept", "Slope"]);
my $regI = Statistics::Regression->new("ACAI",["Intercept", "Slope"]);

#this is a workaround for a flaw in Perl's file reading.


for (@k)
{
    $thisk = $_;
    if ($thisk == 0)
    {
        #this is a workaround for a flaw in Perl's file reading.
        #a test data file with all zeros reads as empty, so the algorithms won't work.
        #yet, we know none of the groups will test positive.
        #therefore we can use the following data for k = 0 regardless of the values for n or trialsperk.
        my @zerokdata = [0,0,0,0,0];
        $regP->include($thisk, [1.0, 0]);
        $regI->include($thisk, [1.0, 0]);
        $csv->say ($fhP,\@zerokdata);
        $csv->say ($fhI,\@zerokdata);
    }
    else
    {
        generateTestData($thisk,$n,$trialsPerK);
        @ACAPresults = ACAP();
        @ACAIresults = ACAI();
        unshift(@ACAPresults,$thisk);
        unshift(@ACAIresults,$thisk);
        $regP->include($thisk, [1.0, $ACAPresults[3]]);
        $regI->include($thisk, [1.0, $ACAIresults[3]]);
        $csv->say ($fhP,\@ACAPresults);
        $csv->say ($fhI,\@ACAIresults);
    }
}
close($fhP);
close($fhI);
say("all trials for all k values complete. calculating linear regressions for ACAP and ACAI...");
open my $fhR, ">:encoding(utf8)", "linear_regression.csv" or die "linear_regression.csv: $!";
$csv->say ($fhR,['n','lowest k','highest k','trials per k','Regression (ACAP)','R^2 (ACAP)','Regression (ACAI)','R^2 (ACAI)']);
my $thetaP = $regP->theta();
my $linP = "y = ".$thetaP->[1]."x ";
if ($thetaP->[0] < 0)
{
    $linP = $linP." ".$thetaP->[0];
}
else
{
    $linP = $linP."+ ".$thetaP->[0];
}
my $thetaI = $regI->theta();
my $linI = "y = ".$thetaI->[1]."x ";
if ($thetaI->[0] < 0)
{
    $linI = $linI." ".$thetaI->[0];
}
else
{
    $linI = $linI."+ ".$thetaI->[0];
}

$csv->say ($fhR,[$n,$k[0],$ARGV[2],$trialsPerK,$linP,$regP->rsq(),$linI,$regI->rsq()]);
close($fhR);
print('done.');
1;