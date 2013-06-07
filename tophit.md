coralAssembly
=============
This is a perl script used for assembly and annotation of coral transcriptome.
==============


# Gets  the parsed file from blast_forked.pl and ranks the top hits. 
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

