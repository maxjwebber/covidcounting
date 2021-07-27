#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
require "ACAI.pl";
require "ACAP.pl";
require "generateTestData.pl";
require "mystats.pl";
use Text::CSV qw(csv);

if ($#ARGV<2)
{
    die "usage: driver.pl -n [value] (required) -kmin [value] (optional) -kmax [value] (optional) -trialsperk [value] (optional)";
}

my $n = -1;
my $mink = 0;
my $maxk = -1;
my $trialsPerK = 10000;

for(my $i = 0; $i <= $#ARGV; $i++)
{
    if ($ARGV[$i] eq '-n')
    {
        $i++;
        $n = $ARGV[$i];
    }
    elsif ($ARGV[$i] eq '-kmin')
    {
        $i++;
        $mink = $ARGV[$i];
    }
    elsif ($ARGV[$i] eq '-kmax')
    {
        $i++;
        $maxk = $ARGV[$i];
    }
    elsif ($ARGV[$i] eq '-trialsperk')
    {
        $i++;
        $trialsPerK = $ARGV[$i];
    }

}

if ($n<1)
{
    die "provide a value for -n [number of subjects]";
}

if ($maxk<0)
{
    $maxk = ceil(0.05 * $n);
}


if ($mink>1)
{
    say "use of lowest # infected greater than 1 is not advised; may skew linear regression."
}

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
my @xP;
my @xI;

my @subsetSizesACAP;
my $progress = ceil($n/2);
push (@subsetSizesACAP,$progress);
my $divisor = 2;
while ($progress < $n) {
    my $next = ceil(floor($n/$divisor)/2);
    push (@subsetSizesACAP,$next);
    $progress += $next;
    $divisor *= 2;
}

for ($mink..$maxk)
{
    $thisk = $_;
    generateTestData($thisk,$n,$trialsPerK);
    @ACAPresults = ACAP(@subsetSizesACAP);
    @ACAIresults = ACAI();
    unshift(@ACAPresults,$thisk);
    unshift(@ACAIresults,$thisk);
    push (@xP,$ACAPresults[3]);
    push (@xI,$ACAIresults[3]);
    $csv->say ($fhP,\@ACAPresults);
    $csv->say ($fhI,\@ACAIresults);
}
close($fhP);
close($fhI);


say("all trials for all k values complete. calculating linear regressions for ACAP and ACAI...");
open my $fhR, ">:encoding(utf8)", "linear_regression.csv" or die "linear_regression.csv: $!";
$csv->say ($fhR,['n','lowest k','highest k','trials per k','Regression (ACAP)','R^2 (ACAP)','Regression (ACAI)','R^2 (ACAI)']);
my @k = ($mink..$maxk);
my $meank = ($mink+$maxk)/2;
my $vark = variance(@k);

my $meanxP = mean(@xP);
my $varxP = variance(@xP);

my $covarxyP = covariance(\@xP,\@k);
my $slopeP = $covarxyP / $varxP;
my $interceptP = $meank - ($slopeP * $meanxP);

my $RsqP = ($covarxyP**2 / ($varxP * $vark));

my $linP = "y = ".$slopeP."x ";
if ($interceptP < 0)
{
    $linP = $linP.$interceptP;
}
else
{
    $linP = $linP."+".$interceptP;
}


my $meanxI = mean(@xI);
my $varxI = variance(@xI);
my $covarxyI = covariance(\@xI,\@k);
my $slopeI = $covarxyI / $varxI;
my $interceptI = $meank - ($slopeI * $meanxI);

my $RsqI = ($covarxyI**2 / ($varxI * $vark));

my $linI = "y = ".$slopeI."x ";

if ($interceptI < 0)
{
    $linI = $linI.$interceptI;
}
else
{
    $linI = $linI."+".$interceptI;
}

$csv->say ($fhR,[$n,$mink,$maxk,$trialsPerK,$linP,$RsqP,$linI,$RsqI]);
close($fhR);
print('done.');
1;