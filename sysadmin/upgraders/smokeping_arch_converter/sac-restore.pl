#!/usr/bin/perl
#
# Smokeping Arch Converter (SAC)
#
# (C) Copyright 2007 Jethro Carr <jethro.carr@jethrocarr.com>
#
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License version 2 as
#  published by the Free Software Foundation;
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
###
### Please see the readme file for information on how to use this script.
###

use strict;


# preferences
my $datadir = "/var/smokeping/datadir/Smokeping/";
my $rrdtool = "/usr/bin/rrdtool";







print "\n";
print "SMOKEPING ARCH CONVERTER (SAC)\n";
print "\n";
print "This script turns the XML files made by the export script into RRD files again in the set smokeping directory. This requires that smokeping has the same configuration as the export system, and that the rrd files and directories have already been created. I would also recommend stopping smokeping before running this script.\n";
print "\n";
print "The script is configured to make the RRD files in $datadir\n";
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
			# found another directory 
			print "Entering directory: $filename\n";
			chdir($filename_short);
			process_directory("$filename");
		}
		else
		{
			print "Found file: $filename_short\n";

			if ($filename_short =~ /(\S*).rrd$/)
			{
				print "Converting XML file & replacing existing RRD file...\n";
				system("rm -f $filename");
				system("$rrdtool restore $1.xml $filename");
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



print "\nConversion Complete! You may need to correct the permissions of the files.\n\n";
exit 0;

