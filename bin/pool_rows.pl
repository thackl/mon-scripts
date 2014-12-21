#!/usr/bin/env perl

use warnings;
use strict;

use Carp;
use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;

use Data::Dumper;
use List::Util;

=head1 NAME

pool_rows.pl

=head1 DESCRIPTION

??

=head1 SYNOPSIS

  $ cat test.tsv | ./pool_rows.pl -c 1,2

=head1 OPTIONS

=over

=item -c|--columns

Zero-based indexes of columns that need to be identical in order to
merge rows. Required.

=item -s|--sort

Zero-based indexes of columns to be sorted by in order of priority.

=item -i|--ignore-header

Ignore header line.

=item -h|--help

Display this help

=back

=cut

my %opt;

GetOptions( # use %opt (Cfg) as defaults
        \%opt, qw(
                ignore_header|ignore-header|i!
                columns|c=s
                sort|s=s
		help|h!
        )
    ) or podusage(1);

# help
$opt{help} && pod2usage(1);

$opt{columns} || pod2usage("-c required");
my @cix = split(/,/, $opt{columns});

my %R;
my $cc;
my @header;
my @R;

while(<>){
    chomp();
    s/^\s+//; # ignore leading whitespace
    my @c  = split(/\s+/, $_);

    if($opt{ignore_header} && !@header){ # do not process header
	@header=("",@c);
	next;
    }

    next unless @c; # ignore emtpy row
    
    # col counter
    $cc = @c-1 unless $cc; 
    # store uniqly
    push @{$R{join("|", @c[@cix])}}, [@c];
};

exit unless $cc;

my @cif = (0) x $cc; # init 

$cif[$_]++ for @cix; # 1: col identical, 0: col to range

if($cc < $#cif){
    pod2usage("non-existing column specified in -c");
}

foreach my $k (sort keys %R){ # loop pools
    my @p = @{$R{$k}};
    my @rp = (scalar @p);
    
    if(@p<2){
	push @rp, @{$p[0]};
    }else{
	foreach my $cx (0..$cc){ # loop cols
	    if($cif[$cx]){ # identical
		push @rp, $p[0][$cx];
	    }else{ # make range
		my @range=range(map{$_->[$cx]}@p);
		push @rp, "[".join("..",@range)."]"; 
	    }
	}
    }
    push @R, \@rp;
}

if($opt{sort}){
    my @sc = map{$_+=1}split(",", $opt{sort}); # account for # col
    my $sorter = get_prio_sorter(@sc);
    @R = sort $sorter @R;
}

unshift @R, \@header if @header;

## compute column widths

my @cw;
my $max_cw = 12;
foreach my $cx (0..$cc+1){
    push @cw, List::Util::max( 
	map{ 
	    if(length($_->[$cx]) > $max_cw){
		$_->[$cx] = substr($_->[$cx], 0, $max_cw);
		$max_cw;
	    }else{
		length($_->[$cx]) 
	    }
	}@R 
	);
}

@cw=map{"%".$_."s"}@cw;

printf(join("  ", @cw)."\n", @$_) for @R;



sub range{
    my @b = $_[0] =~ /^[\d]+$/
	? (sort{$a<=>$b}@_)[0,$#_]
	: (sort @_)[0,$#_];
    return @b;
}

sub get_prio_sorter{
    my @si = @_;
    die "indices required" unless @si;
    my $sorter_core = '$a->[$si[0]] cmp $b->[$si[0]]';
    for(my $i=1;$i<@si;$i++){
        $sorter_core .= '|| $a->[$si['.$i.']] cmp $b->[$si['.$i.']]';
    }
    my $sorter = eval "sub { $sorter_core }";
    return $sorter;
}
