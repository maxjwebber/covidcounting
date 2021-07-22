#!/usr/bin/perl
use 5.32.1;
use strict;
use warnings FATAL => 'all';

sub mean
{
    my @data = sort @_;
    my $total = 0;
    my $numVals = 0;
    foreach $a (@data)
    {
        $total += $a;
        $numVals++;
    }
    return $total / $numVals;
}

sub covariance
{
    #this needs array refs instead of actual arrays as arguments
    #because perl functions can only accept one array
    my ($x_ref, $y_ref) = @_;
    my @X = @{$x_ref};
    my @Y = @{$y_ref};
    my $length1 = @X;
    my $length2 = @Y;
    if ($length1 != $length2)
    {
        die "Lengths of the sets used don't match. Can't get variance.";
    }
    my $EX = mean(@X);
    my $EY = mean(@Y);
    #E[(X−EX)(Y−EY)]
    my @covar_terms;
    for(my $i = 0; $i < $length1; $i++){
        my $firstterm = $X[$i] - $EX;
        my $secondterm = $Y[$i] - $EY;
        push (@covar_terms,$firstterm * $secondterm);
    }
    my @sorted = sort @covar_terms;
    my $total = 0;
    foreach $a (@sorted)
    {
        $total += $a;
    }
    return $total / ($length1-1);
}

sub variance
{
    my @X = @_;
    my $length = @X;
    my $EX = mean(@X);
    #E[(X−EX)^2]
    my @var_terms;
    for(my $i = 0; $i < $length; $i++){
        my $term = $X[$i] - $EX;
        push (@var_terms,$term * $term);
    }
    my @sorted = sort @var_terms;
    my $total = 0;
    foreach $a (@sorted)
    {
        $total += $a;
    }
    return $total / ($length-1);
}
1;