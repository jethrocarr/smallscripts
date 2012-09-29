#!/usr/bin/perl -w


# tell perl we need the Time::Local module
use Time::Local;


# show original
$time = "200802221449";
print "Old date/time is $time\n";

# convert the text field into a time stamp
$time =~ /^([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})$/;
$timestamp = timelocal(0,$5,$4,$3,($2 - 1),$1);

print "Timestamp is: $timestamp\n";
# make your change - example is adding 1hr of time
$timestamp = $timestamp + 3600;

# convert the time stamp into a text field again
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timestamp);

# do formatting to suit text field type (sprintf pads all the values with 00)
$year	= $year + 1900;
$mon	= sprintf("%02d", ($mon + 1));	# we need to add 1 to the month, since perl uses months 0-11 rather than 1-12
$mday	= sprintf("%02d", $mday);
$hour	= sprintf("%02d", $hour);
$min	= sprintf("%02d", $min);
$time	= $year . $mon . $mday . $hour . $min;



# show change
print "New date/time is $time\n";


