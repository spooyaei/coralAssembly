#!/usr/bin/perl

use strict;
use warnings;
use File::Temp qw/tempfile/;
use Getopt::Long;

my $DEFAULT_BINS = [250, 1000, 10000];
my $DEFAULT_MINLENGTH = 100;
my $DEFAULT_NPERC     = 10;

sub sum {
    my ($contigs) = @_;
    my $sum = 0;
    map { $sum += $_ } @$contigs;
    return $sum;
}

sub median {
    my ($contigs) = @_;
    my $size = scalar @$contigs;
    if ($size % 2 == 1) {
        return $contigs->[ ($size + 1) / 2 ];
    } else {
        return ($contigs->[ $size / 2 ] + $contigs->[ ($size + 2) / 2 ]) / 2;
    }
}

sub usage {
    print <<USAGE;
Usage: $0 [options] sequence.fa
       $0 [options] < sequence.fa
Produces a set of statistics on an assembly of contigs contained in "sequence.fa"

    -b,--bins=ARG1,ARG2,...      Produce contigs counts above comma-separated ARG bins [DEFAULT: @{[join(",", @$DEFAULT_BINS)]}]
    -h,--help                    This help message
    -l,--length=ARG              Only examine contigs of length >= ARG [DEFAULT: $DEFAULT_MINLENGTH]
    -p,--percentiles=ARG         Produce assembly percentile sizes (e.g. N50) at ARG intervals [DEFAULT: $DEFAULT_NPERC]
USAGE
    exit 0;
}

sub sort_lengths {
    my ($contigs) = @_;
    
    my ($out, $filename) = tempfile();
    while (my $contig = pop @$contigs) {
        print $out "$contig\n";
    }
    close $out;
    open my $in, "sort -n $filename|"
        or die "Can't open temp file for sorting:$!\n";
    while (my $line = <$in>) {
        chomp $line;
        push @$contigs, $line;
    }
    close $in;
}

sub cumsum {
    my ($p) = @_;
    my $c = sub  : lvalue {
        $p->[ shift() ]->[1]->[1];
    };
    my $sum = $c->($#$p);
    $c->($#$p) = 1;
    for (my $i = $#$p - 1; $i >= 0; $i--) {
        $sum += $c->($i);
        $c->($i) = $sum;
    }
}

sub calculate_stats {
    my $contigs      = shift;
    my $nperc        = shift || $DEFAULT_NPERC;
    my $contig_sizes = shift || $DEFAULT_BINS;

    my $ncontigs = scalar @$contigs;
    return 0 unless ($ncontigs > 0);
    my %size_counts = map { $_ => 0 } @$contig_sizes;

    my $inc = 100 / $nperc;

    my $length = sum($contigs);
    my $perc       = 0;
    my $perclength = $length * ($inc / 100);
    my $target_sum = 0;

    my @percentiles = ();

    my $running_sum  = 0;
    my $last_contig  = 0;
    my $contig_count = 0;
    sort_lengths($contigs);
    for my $contig (@$contigs) {
        $contig_count++;
        if (   ($running_sum <= $target_sum)
            && ($running_sum + $contig >= $target_sum))
        {
      my $nperc = 100 - $perc;
            push @percentiles, [ "N$nperc" => [ $contig, $contig_count ] ];
            $perc       += $inc;
            $target_sum += $perclength;
            $contig_count = 0;
        }
        for my $size (keys %size_counts) {
            $size_counts{$size}++ if ($contig >= $size);
        }
        $running_sum += $contig;
        $last_contig = $contig;
    }
    # Due to a very strange bug that occurs some of the time...
    if ($percentiles[$#percentiles]->[0] ne "N0") {
        push @percentiles, [ N0 => [ $contigs->[$#$contigs], 1 ] ];
    }
    cumsum(\@percentiles);
    my $median_contig = median($contigs);
    my @stats = (
        [ 'Contigs',      $ncontigs ],
        [ 'Total length', $length ],
        [ 'Mean contig',   sprintf("%2.2f", $length / $ncontigs) ],
        [ 'Median contig', $median_contig ],
        map({ [ "n>=${_}nt", $size_counts{$_} ] } @$contig_sizes),
        map({ [ $_->[0], sprintf("%12d %12d", @{ $_->[1] }) ] } @percentiles),
    );
    return \@stats;
}

sub load_contigs {
    my ($contigs, $fh, $minlength) = @_;
    my @sequence = ();
    my $add_contig = sub {
        my $seqlen = length(join "", @sequence);
        if ($seqlen >= $minlength) {
            push @$contigs, $seqlen;
        }
    };
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ m/^>/) {
            if (scalar @sequence > 0) {
                $add_contig->();
            } 
            @sequence = ();
        } else {
            push @sequence, $line;
        }
    }
    $add_contig->();
}

MAIN: {
    my $minlength = $DEFAULT_MINLENGTH;
    my $nperc     = $DEFAULT_NPERC;
    my $help;
    my $bins = undef;
    my $bin_sizes;
    GetOptions(
        'length|l=i' => \$minlength,
        'help|h'     => \$help,
        'bins|b=s'   => \$bins,
        'percentiles|p=s' => \$nperc,
    ) || usage();
    if ($help) {
        usage();
    }
    if ($bins) {
        $bin_sizes = [split ',', $bins];
    } else {
        $bin_sizes = undef;
    }
    my @contigs = ();

    my $fh;
    if (defined $ARGV[0]) {
        open($fh, '<', $ARGV[0]) or die "Can't open file $ARGV[0] for reading: !$\n";
    } else {
        $fh = \*STDIN;
    }

    load_contigs(\@contigs, $fh, $minlength);
    close($fh);

    my $stats = calculate_stats(\@contigs, $nperc, $bin_sizes);
    for my $stat (@$stats) {
        printf "%-15s %12s\n", @$stat;
    }
}

