#!/usr/bin/perl -w
# cool jethro script version 2.0

use strict;

my $string = '0123^C4567^T^Q890:123^C4567^T^Q890';
my $newstring;

foreach my $char (split(//, $string))
{
	if ($char =~ /[A-Z0-9:]/)
	{
		$newstring .= $char;
	}
}

print "Final: $newstring\n";


