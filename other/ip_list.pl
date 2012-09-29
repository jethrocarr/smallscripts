#!/usr/bin/perl -w
#
# Generates a list of all IPs in the range
#
# Currently assumes /24 network
#

my $iprange	= "10.8.10.";

foreach (my $i = 0; $i <= 255; $i++)
{
	print $iprange . $i ."\n";
}


