#!/usr/bin/perl
#
# Timeout & shutdown script
#
# Copyright 2007, Jethro Carr <jethro.carr@jethrocarr.com>
# Licenced under the GNU GPL version 2 or later.
#
# This script checks for users logged in (as visible with who) and
# if samba is installed, will check if anyone is using any shares.
#
# If the answer to the above is "no", after a set timeout, it
# will shutdown the computer. This is useful if you like to use
# your computer to share files, but don't want it to be "always on".
#
#
# USAGE:
#
#	Run the script from the CLI to get debug information
#	It will tell you if it finds the who and smbstatus programs. If
#	everything is working, add it to the root user's crontab.
#
#	Crontab example for running the script every 15mins:
#	*/15 * * * * <scriptlocation&name> >> /dev/null
#
#	Crontab example for running the script once every 15mins between 9pm and 4am.
#	*/15 0-4,21-23 * * * <scriptlocation&name> >> /dev/null
#
#	Note: the " >> /dev/null" addition is used to delete the program's output
#	messages. If you want them, remove it, and program output will be emailed
#	to you.
#

use strict;


#### SETTINGS ####

# how long before shutting down (in minutes)
my $timeout = "120";

# program locations
my $location_who	= "/usr/bin/who";
my $location_smbstatus	= "/usr/bin/smbstatus";


#### PROGRAM ####

my $busyflag = 0;


# check if who is installed
if ( -e $location_who )
{
	my $output_who = `$location_who`;

	# if data was returned, set the system to busy
	if ($output_who)
	{
		$busyflag = 1;
	}
}
else
{
	print "Unable to find the who program. Quitting.\n";
	exit 1;
}

# check if smbstatus is installed
if ( -e $location_smbstatus )
{
	# get the information, and generate a final value with all the data in it.
	my $output_smbstatus;
	system("$location_smbstatus -S > /tmp/autoshutdown-data");
	open(IN, "/tmp/autoshutdown-data");
	while (<IN>)
	{
		chomp ($_);

		if ($_)
		{
			if ($_ !~ /----/ && $_ !~ /Service\s*pid/)
			{
				$output_smbstatus .= $_;
			}
		}
	}
	close(IN);
	system("rm /tmp/autoshutdown-data");

	# if data was returned, set the system to busy
	if ($output_smbstatus)
	{
		$busyflag = 1;
	}
}
else
{
	print "No smbstatus program was found. Assuming samba not installed.\n";
}

# are we busy?
if ($busyflag)
{
	print "There are currently users logged in and/or using samba\n";
	print "Clearing shutdown timer.\n";
	system("rm /tmp/autoshutdown-timer >> /dev/null 2>&1");
}
else
{
	print "System is not currently in use. Processing timer.\n";

	my $currenttime = time();
	my $timeout_secs = $timeout * 60;

	# if it exists, get the time value.
	if ( -e "/tmp/autoshutdown-timer" )
	{
		my $previoustime;
		open(IN,"/tmp/autoshutdown-timer");
		
		while (<IN>)
		{
			$previoustime = $_;
		}
		
		close(IN);

		# check the time
		if ($previoustime > ($currenttime - $timeout_secs))
		{
			print "System has not yet timed out. Leaving script.\n";
			exit 0;
		}
		else
		{
			print "System has timed out. Initiating shutdown....\n";
			system("rm /tmp/autoshutdown-timer >> /dev/null 2>&1");
			system("/sbin/shutdown -h now");
		}
	}
	else
	{
		# set the timer file
		print "Creating the timer file\n";
		open(OUT,">/tmp/autoshutdown-timer");
		print OUT $currenttime;
		close(OUT);
	}
}

exit 0;
