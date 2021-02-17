#!/usr/bin/perl
use 5.32.1;
use warnings FATAL => 'all';
use List::Util qw(shuffle);
use Time::HiRes qw(gettimeofday tv_interval);
#0 is not infected, 1 is infected

#subroutine params: how many infected, size of the pool, how many lines of test data

sub generateTestData
{
    my $t0 = [gettimeofday];
    my $total_time_printing = 0;
    my $total_time_shuffling = 0;
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
    my $elapsed = tv_interval ($t0);
    say "filling the array took $elapsed seconds.";

    my $filename = "testdata.txt";

    open(FH, '>', $filename) or die $!;

    for (1..$num_lines){
        $t0 = [gettimeofday];
        @testpool = shuffle(@testpool);
        $elapsed = tv_interval ($t0);
        $total_time_shuffling += $elapsed;
        #say "shuffling a line took $elapsed";
        #say("$_");
        $t0 = [gettimeofday];
        say FH @testpool;
        $elapsed = tv_interval ($t0);
        #say "printing a line took $elapsed";
        $total_time_printing += $elapsed;
    }
    close(FH);
    say "shuffling took $total_time_shuffling seconds, printing took $total_time_printing seconds.";
}
1;