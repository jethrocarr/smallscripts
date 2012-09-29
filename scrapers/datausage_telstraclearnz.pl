#!/usr/bin/perl -w
#
# datausage_telstraclearnz.pl
#
# (C) Copyright 2008 Jethro Carr <jethro.carr@jethrocarr.com>
# Licensed under the GNU GPL license version 2 only.
#
# This script downloads the data usage information from Telstra Clear
# and sends a report out via email.
#
# This script is designed to be simple, and hopefully easy to maintain,
# since telstraclear have the annoying habit of changing their interface
# every couple of months.
# 

use strict;

use LWP::UserAgent;

# settings
my $username = "SETME";
my $password = "SETME";
my $debug = 0;
my $telstra_url = "https://www.telstraclear.co.nz/tools/usagemeter";

## PROGRAM ##

my $session_id;
my $session_url_summary;
my %usage_data;

## Prepare the user agent
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0");
$ua->cookie_jar({ file => "cookies.txt" });


## Authenticate

# post the login variables to the form
my $req = HTTP::Request->new(POST => "$telstra_url/index.cfm?s=c");
$req->content_type("application/x-www-form-urlencoded");
$req->content("usageLogin=&fquid=&pass=&acc=$username&pik=$password");

# fetch the results
my $res = $ua->request($req);


# The following line is returned if we authenticate successfully:
# Location: https://www.telstraclear.co.nz//tools/usagemeter/index.cfm?g=C5D83110-0FF8-8798-EA3B6F439D7578A4&s=c&p=listservices

if ($res->as_string =~ m/index.cfm\?g=(\S*)&/)
{
	$session_id = $1;
	print "Session ID is: $session_id\n" if $debug;
}
else
{
 	print $res->as_string if $debug;
	die("Unable to authenticate");

}



# download services list
$req = HTTP::Request->new(GET => "$telstra_url/index.cfm?g=$session_id&s=c&p=listservices");
$res = $ua->request($req);

# the results will include links to all the time periods the user
# has been billed for. We want the stats for the latest one.
#
# Each link looks like something like this:
# <td class="usg_menuCurrent" valign="top"><nobr><a href="https://www.telstraclear.co.nz//tools/usagemeter/index.cfm?g=C5DBB090-E046-D92B-DAA76A676485AB0E&s=c,c&p=usagesummary&display_service=1&service=OnNet&next_bill_date=20080907000000" class="usg_menuCurrent">10 Aug 2008 - Today</a></nobr></td>
#
# We can use the "Today" keyword to detect the correct URL, which we then load.
#if ($res->as_string =~ m/(index.cfm?g=\S*&s=c,c&p=usagesummary&display_service=[0-9]*&service=\S*&next_bill_date=[0-9]*)[\S\s]*Today/)
if ($res->as_string =~ m/<a\shref=\"(\S*)\"\sclass="usg_menuCurrent">[0-9]*\s[A-Za-z]{3}\s[0-9]{4}\s-\sToday<\/a>/)
{
	$session_url_summary = "$1";
	print "Session summary page URL is $session_url_summary\n" if $debug;

#	# for some strange reason, sometimes the URL ends up with "s=c,c" instead of the correct "s=c" option.
#	$session_url_summary =~ s/s=c,c/s=c/;
}
else
{
	print $res->as_string if $debug;
	die("Unable locate link to summary page");

}


# download summary for current billing period
$req = HTTP::Request->new(GET => "$session_url_summary");
$res = $ua->request($req);

# run through all the returned content and gather the values we need
foreach my $line (split('\n', $res->as_string))
{
	chomp($line);

	if ($line =~ /Summary Graph: ([0-9]*\s[A-Za-z]{3}\s[0-9]{4})[\S\s]*which\sends\son:\s<b>\s([0-9]*\s[A-Za-z]{3}\s[0-9]{4})<\/b>/)
	{
		$usage_data{"period_start"}	= $1;
		$usage_data{"period_end"}	= $2;
	}

	if ($line =~ /You\shave\sused\s<strong>\s([0-9.]*\s[A-Z]{2})<\/strong>/)
	{
		$usage_data{"used"} = $1;
	}

	if ($line =~ /You\shave\s<strong>\s([0-9.]*\s[A-Z]{2})<\/strong>\sleft/)
	{
		$usage_data{"left"} = $1;
	}


}

# display final report
print "Telstraclear NZ Data Usage Report\n";
print "Account $username\n";
print "\n";
print "Period from ". $usage_data{"period_start"} ." to ". $usage_data{"period_end"} ."\n";
print "\n";
print "Used data:\t". $usage_data{"used"} ."\n";
print "Remaining data:\t". $usage_data{"left"} ."\n";
print "\n";


