#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
use POSIX;
use Statistics::Descriptive;
use feature 'unicode_strings';
sub ACAP
{
    #0 is not infected, 1 is infected
    my @testdata;
    my $Y;
    my @valuesY;
    my @values2totheY;

    my $subset_size;
    my $filename = "testdata.txt";

    #GOALS FOR THIS ITERATION:
    #implement partition variant of ACA1
    #estimate EY and E(2^Y) using the sample mean.
    #estimate Var(Y) and Var(2^Y) using the sample variance.
    #compare speed and accuracy to that of ACAI

    #ACAP is:
    #Number the samples randomly 1 through n.
    #(the order of the samples is already randomized when creating test data so we can arbitrarily number them by order of their indices)
    #Partition the people into subsets of size ⌈n/2⌉, ⌈n/4⌉, ⌈n/8⌉, ⌈n/16⌉, ….
    #Let Y = the number of subsets that test positive. Then EY ≈ log(k) where k is the number of infected individuals.

    open(FH, "<", $filename) or die $!;

    #this program will perform one trial of the ACA1 algorithm for each line of test data
    my $stat = Statistics::Descriptive::Sparse->new();
    my $testdatastring;
    my $n;
    my $firstindex;
    my $lastindex;
    while(<FH>){
        $n = ((length $_) - 1);
        $testdatastring = substr($_, 0, $n);
        #for each line in the file, transform binary string to character list
        @testdata = split (//, $testdatastring);
        $Y = 0;
        $firstindex = 0;
        $subset_size = $n;
        while ($firstindex < $n)
        {
            #increase divisor by factor of 2, creating smaller and smaller subsets
            $subset_size = ceil($subset_size / 2);
            $lastindex = ($firstindex + $subset_size - 1 < $n) ? $firstindex + $subset_size - 1 : $n-1;
            #Let Y = the number of subsets that test positive.
            #increase count of Y if someone in the selected subset is infected
            for my $i ($firstindex..$lastindex)
            {
                if($testdata[$i] == 1)
                {
                    $Y++;
                    last; #exit for loop
                }
            }
            $firstindex = $lastindex + 1;
        };
        push(@valuesY,$Y);
        push(@values2totheY,(2**$Y));
    }
    close(FH);

    $stat->add_data(@valuesY);

    #estimate expected value of Y
    my $sample_mean_Y = $stat->mean();
    #say "Sample Mean of Y is $sample_mean_Y. This is an unbiased estimator for EY.";

    #estimate variance of Y
    my $sample_variance_Y = $stat->variance();
    #say "Sample Variance is $sample_variance_Y. This is an unbiased estimator for Var(Y).";

    $stat->clear();
    $stat->add_data(@values2totheY);

    #estimate expected value of 2^Y
    my $sample_mean_2totheY = $stat->mean();
    #say "Sample Mean of 2^Y is $sample_mean_2totheY. This is an unbiased estimator for E(2^Y).";

    #estimate variance of 2^Y
    my $sample_variance_2totheY = $stat->variance();
    #say "Sample Variance is $sample_variance_2totheY. This is an unbiased estimator for Var(2^Y).";

    return ($sample_mean_Y,$sample_variance_Y,$sample_mean_2totheY,$sample_variance_2totheY);
}
1;