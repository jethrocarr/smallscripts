#!/usr/bin/perl -w
#
# This script reads in a text file, does a lookup of all the IP addresses and replaces them with their reverse lookup.
# Useful for processing cvs files with IP flow records.
#
# Usage:
# ./ip2dns.pl <inputfilename>
#

use strict;

## SETTINGS ##
my $filename	= $ARGV[0];
my $cmd_host	= "/usr/bin/host";

# cache for IP addresses (saves us to having to repeatedly
# call the host command)
my %lookup_table;


## CHECKS ##
# make sure we have an input file

if (!$filename)
{
	die("Usage:\n./ip2dns.pl <inputfilename>\n");
}


## PROGRAM ##

# run through all rows
open(IN, $filename) || die("Error: Unable to open input file $filename\n");

while (my $line = <IN>)
{
	# because a single line may have multiple IP addresses, we keep looping until
	# we run out of IP addresses to look up. Once that happens we print the line
	# to screen.
	#
	# Any IP addresses that do not have a reverse DNS lookup, we just ignore.
	#
	# But this would cause a problem - if we have an IP we can't resolve, it would
	# remain as it is, and repeatedly be looked up! To fix that, we make all the changes
	# to the $new_line variable, and cut the ip out of the old line until we run out of
	# IP addresses to look up in the line.
	#

	my $complete = 0;
	my $new_line = $line;

	while (!$complete)
	{
		my $replace;
		my $ip_address;

		if ($line =~ /([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*)/)
		{
			# An IP has been found. Get the DNS record for it.
			# If we can't find a DNS record, we will just leave
			# the IP as it is.

			$ip_address = $1;


			if (!$lookup_table{"$ip_address"})
			{
				# Look up the IP and add it to the cache table
				my $command = "$cmd_host $ip_address";

				open(HOST, "$command |") || die("Unable to execute $command\n");

				while (my $cmd_output = <HOST>)
				{
					if ($cmd_output =~ /domain\sname\spointer\s(\S*)./)
					{
						$lookup_table{"$ip_address"} = $1;
					}

				}
				close(HOST);

				# name does not resolve. so just stick the IP in to prevent
				# repeated lookups
				if (!$lookup_table{"$ip_address"})
				{
					$lookup_table{"$ip_address"} = $ip_address;
				}
			}

			# grap the IP resolve from the cache
			$replace = $lookup_table{"$ip_address"};
			

			# if we have a DNS name, replace it in the line.
			if ($replace)
			{
				$new_line =~ s/$ip_address/$replace/g;
			}

			# remove the IP from the old line
			$line =~ s/$ip_address//g;
		}
		else
		{
			# there are no more IP addresses. Stop checking this line.
			$complete = 1;
		}

	}

	# woot! results!
	print $new_line;
	
}

close(IN);


exit 0;
