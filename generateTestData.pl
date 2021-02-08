#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
use List::Util qw(shuffle);

#0 is not infected, 1 is infected

#subroutine params: how many infected, size of the pool, how many lines of test data

sub generateTestData()
{
    my $num_infected = $_[0];
    my $num_testpool = $_[1];
    my $num_lines= $_[2];
    my @testpool;
    my @countA = (1..$num_infected);
    for (@countA){
        #say("$_");
        push (@testpool,1);
    }
    my @countB = (($num_infected+1)..$num_testpool);
    for (@countB){
        #say("$_");
        push (@testpool,0);
    }

    my $filename = "testdata.txt";

    open(FH, '>', $filename) or die $!;

    for (1..$num_lines){
        @testpool = shuffle(@testpool);
        #say("$_");
        say FH @testpool;
    }
    close(FH);
}
