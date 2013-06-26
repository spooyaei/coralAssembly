#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;

## Stage A ##
# soon...


## Stage B ##
# get as input the file from blast_forked.pl
my $in1 = ' Histon.poly.withhit '; # will be replaced with the output of Stage A
open IN1, $in1 or die("$!\n");
my @rows = grep { !/^\w+\s+\d+\s+No\s+/ } <IN1> ;
close IN1;


my @rr =  map { join "\t", (split)[0,2,7] } @rows;

@rr = sort {
                        (split /\t/, $a)[4] <=>
                       (split /\t/, $b)[4]
            } @rr;

my %rr = map { (split /\t/, $_)[0] => $_ } @rr;

# print map { $rr{$_} ,"\n" } sort keys %rr;
#
@rr = map { $rr{$_} } sort keys %rr;

 

# debug
print map { $_, "\n"} @rr;  
