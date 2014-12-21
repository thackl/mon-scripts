#!/usr/bin/env perl
use warnings;
use strict;

my $sorter = eval 'sub {print "sorting\n"; $b <=> $a}';

my @c = 1..5;

my @s = sort $sorter @c;
print @s,"\n";


