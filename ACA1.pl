#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
use POSIX;
use List::Util qw(sample);
use List::Util qw(any);

sub ACA1
{
    #0 is not infected, 1 is infected
    my @testpool;
    my $Y;
    my $totalY;
    my $totalsquaredY;
    my $total2totheY;
    my $total2tothe2Y;
    my $total4totheY;
    my $total4tothe2Y;

    my @subset;
    my $subset_size;
    my $subset_divisor;
    my $trialsACA1;
    my $filename = "testdata.txt";

    #GOALS FOR THIS ITERATION:
    #estimate EY using the sample mean.
    #estimate Var(Y) using the sample variance.

    #ACA1 is:
    #Number the samples randomly 1 through n.
    #(the order of the samples is already randomized when creating test data so we can arbitrarily number them by order of their indices)
    #Choose independently subsets of size ⎾n/2⏋, ⎾n/4⏋, ⎾n/8⏋, ⎾n/16⏋, …, 1.
    #Let Y = the number of subsets that test positive. Then EY ≈ log(k) where k is the number of infected individuals.

    open(FH, '<', $filename) or die $!;

    #this program will perform one trial of the ACA1 algorithm for each line of test data
    $trialsACA1 = 0;
    $totalY = 0;
    $total2totheY = 0;
    $total4totheY = 0;

    my $testpoolstring;
    my $n;
    while(<FH>){
        $n = ((length $_) - 1);
        $testpoolstring = substr($_, 0, $n);
        #for each line in the file, transform binary string to character list
        @testpool = split (//, $testpoolstring);
        #count the lines/number of trials
        $trialsACA1++;
        #init subset_divisor and Y
        $subset_divisor = 1;
        $Y = 0;
        do
        {
            #increase divisor by factor of 2, creating smaller and smaller subsets
            $subset_divisor*=2;
            #Choose independently subsets of size ⎾n/2⏋, ⎾n/4⏋, ⎾n/8⏋, ⎾n/16⏋, …, 1.
            $subset_size = ceil($n / $subset_divisor);
            @subset = sample $subset_size, @testpool;
            #Let Y = the number of subsets that test positive.
            #increase count of Y if someone in the selected subset is infected
            if (any {$_ == 1} @subset)
            {
                $Y++;
            }
        }while ($subset_size > 1);
        $totalY += $Y;
        $totalsquaredY += ($Y**2);
        $total2totheY += (2**$Y);
        $total2tothe2Y += (2**(2*$Y));
        $total4totheY += (4**$Y);
        $total4tothe2Y += (4**(2*$Y));
    }
    close(FH);

    #say "$trialsACA1 trials were performed.";
    #estimate expected value of Y
    my $sample_mean_Y = $totalY / $trialsACA1;
    #say "Sample Mean of Y is $sample_mean_Y. This is an unbiased estimator for EY.";

    #estimate variance of Y
    my $sample_variance_Y = (1/($trialsACA1 - 1))*($totalsquaredY - ($trialsACA1*($sample_mean_Y**2)));
    #say "Sample Variance is $sample_variance_Y. This is an unbiased estimator for Var(Y).";

    #estimate expected value of 2^Y
    my $sample_mean_2totheY = $total2totheY / $trialsACA1;
    #say "Sample Mean of 2^Y is $sample_mean_2totheY. This is an unbiased estimator for E(2^Y).";

    #estimate variance of 2^Y
    my $sample_variance_2totheY = (1/($trialsACA1 - 1))*($total2tothe2Y - ($trialsACA1*($sample_mean_2totheY**2)));
    #say "Sample Variance is $sample_variance_2totheY. This is an unbiased estimator for Var(2^Y).";

    #estimate expected value of 4^Y
    my $sample_mean_4totheY = $total4totheY / $trialsACA1;
    #say "Sample Mean of 4^Y is $sample_mean_4totheY. This is an unbiased estimator for E(4^Y).";

    #estimate variance of 4^Y
    my $sample_variance_4totheY = (1/($trialsACA1 - 1))*($total4tothe2Y - ($trialsACA1*($sample_mean_4totheY**2)));
    #say "Sample Variance is $sample_variance_4totheY. This is an unbiased estimator for Var(4^Y).";

    return ($sample_mean_Y,$sample_variance_Y,$sample_mean_2totheY,$sample_variance_2totheY,$sample_mean_4totheY,$sample_variance_4totheY);
}
1;