#!/usr/bin/perl -w
#
# Perl is awesome. Except for when it's not.
#
# This script pulls an IP address off ifconfig
#

my $dev		= "wlan2";
my $cmd		= "/sbin/ifconfig $dev";
my $debug	= 0;


open(CMD, "$cmd|");

while (<CMD>)
{
	chomp($_);

	print "debug:". $_ ."\n" if $debug;

	if ($_ =~ m/inet\saddr:(\S*)\s/)
	{
		print "ip address is: $1\n";
	}
}


