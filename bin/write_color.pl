#!/usr/bin/perl

use strict;
use warnings;
use Term::ANSIColor;


my$string=shift(@ARGV);


while(<>)
{
    if($string && $_=~/$string/)
    {
	print color("red"), $_, color("reset") if $_=~/$string/;
    }
    else
    {
	print $_;
    }
}
