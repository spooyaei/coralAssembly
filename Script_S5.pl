#!/usr/bin/perl
#
# extract-nuc.pl
#
# This script takes getorf output and original input and extracts the
# nucleotide sequences. The script writes to STDOUT the getorf data with
# nucleotide data instead.

use Bio::Index::Fasta;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Location::Simple;
use Getopt::Std;

use strict;

my %opts = ();
getopts ('n:a:', \%opts);
my $nucfile = $opts{'n'};
my $aafile = $opts{'a'};

# index the nucleotide data for fast random IO access
my $aa_in = Bio::SeqIO->new(-file => $aafile , '-format' => 'Fasta');
my $nuc_idx = Bio::Index::Fasta->new(-filename => $nucfile . ".idx", -write_flag =>  1 );
$nuc_idx->make_index($nucfile);

# go throught the output and extract each ORF
while (my $aa = $aa_in->next_seq()) {
  my $aa_id = $aa->display_id();
  my $aa_desc = $aa->desc();
  $aa_desc =~ s/\[//;
  $aa_desc =~ s/\s+//g;
  my ( $coords, $rev ) = split(/\]/, $aa_desc);
  my ( $start, $end ) = split( /-/, $coords );

  if ( $start > $end ) # check if the ORF is reverse sense
  {
      $rev = $start; # use $rev as a temporary variable
      $start = $end;
      $end = $rev;
      $rev = -1; # the strand is reversed
  }
  else 
  {
      $rev = 0; # the strand is not reversed
  }

  # parse each ORF and get the data from the nucleotide file
  my ( $contig, $orf_id ) = split( /_/, $aa_id);
  my $nuc = $nuc_idx->fetch($contig);

  # extract the subsequence
  my $loc = Bio::Location::Simple->new(-start => $start, -end => $end, -strand => $rev );

  # print the results
  print ">", $aa->display_id(), " ", $aa->desc(), "\n", $nuc->subseq($loc), "\n";
 
}

exit;
