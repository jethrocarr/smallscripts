#!/usr/bin/perl -w
#
# Generates a list of IP addresses based on the provided options
# suitable for reverse lookup.
#
# Currently assumes /24 network
#

my $iprange	= "192-168-0-";
my $domain	= "example.com";

foreach (my $i = 0; $i <= 255; $i++)
{
	print "$i\t\tPTR\t\t$iprange$i.$domain\n";
}


