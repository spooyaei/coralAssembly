#!/usr/bin/perl -w

# Written by Shaadi P.Mehr on Thursday 11:00 A.M.2011.
## Goal-- to generate small fasta files from a biger fasta file
### based on the given Id list in a new text file

##Usage  ./getsubfasta.pl  list.txt sam23.orf.txt 

use warnings;
use strict;
use Bio::SeqIO;
use Bio::SearchIO;
my $idsfile = shift @ARGV ; # ID to extract 
my $seqfile = "eel31transabyscontigjul23.fas  ";
my %ids  = ();


open IN, $idsfile;
while(<IN>) {

  chomp;
  $ids{$_} += 1;

}
close IN;

local $/ = "\n>";  # read by FASTA record


open FASTA, $seqfile;
while (<FASTA>) {

    chomp;
    my $seq = $_;

    my ($id) = $seq =~ /^>*(\S+)/;  # parse ID as first word in FASTA header
 

# my $aa_desc = $seq->desc();
 # $aa_desc =~ s/\[//
#my $desc=~ split (/\-/, $seq);
 if (exists($ids{$id})) {

       # $seq =~ s/^>*.+\n//;  # remove FASTA header
       # $seq =~ s/\n//g;  # remove endlines

        print ">$seq\n";
   
 

}
}
close FASTA;
