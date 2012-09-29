#!/usr/bin/perl
#
# Smokeping Arch Converter (SAC)
#
# Please see the readme file for information on how to use this script.
#

use strict;


# preferences
my $datadir = "/var/smokeping/datadir/Smokeping/";
my $rrdtool = "/usr/bin/rrdtool";





print "\n";
print "SMOKEPING ARCH CONVERTER (SAC)\n";
print "\n";
print "This script dumps all the RRD data in your smokeping directory into XML files in your current directory. You can then use the restore script to import them to RRD files\n";
print "The script is configured to look in $datadir for RRD files\n";
print "\n";
print "Press <enter> to begin, or <ctl+c> to cancel\n";
my $junk = <STDIN>;




sub process_directory($)
{
	my $directory = shift;
	
	# glob for all the files
	my @filelist = glob("$directory/*");

	foreach my $filename (@filelist)
	{
		$filename =~ /^\S*\/(\S*)$/;
		my $filename_short = $1;
		
		if (-d $filename)
		{
			# found another directory - create the XML one, and process the RRD one
			print "Entering directory: $filename\n";
			system("mkdir $filename_short");
			chdir($filename_short);
			process_directory("$filename");
		}
		else
		{
			print "Found file: $filename_short\n";

			if ($filename_short =~ /(\S*).rrd$/)
			{
				print "File is an RRD file. Converting to XML....\n";
				system("$rrdtool dump $filename > $1.xml");
			}
			else
			{
				print "File is not RRD data, will ignore.\n";
			}
		}
		
	} # end of foreach loop
	
} # end of process_directory()


# call the function the first time.
process_directory($datadir);



print "\nConversion Complete!\n\n";
exit 0;

