#!/bin/bash
# Jethro's OpenSSH Chroot Generater
# (C) Copyright 2007 Jethro Carr <jethro.carr@jethrocarr.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License Version 2 as published by
#    the Free Software Foundation;
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#


# Set the applications you want to be in the chroot here:
# (full path names required)
APPS="/bin/bash /bin/ls /bin/mkdir /bin/mv /bin/pwd /bin/rm /bin/cat /usr/bin/id /usr/bin/ssh /bin/ping /usr/bin/dircolors /usr/bin/whoami"


echo "Welcome to Jethro's OpenSSH Chroot Generator."
echo "This script is licenced under the GNU GPL version 2"
echo ""
echo "INSTRUCTIONS:"
echo "* This script is designed for generating chroot jails for use with OpenSSH with Chroot support http://chrootssh.sourceforge.net/"
echo ""
echo "* You can set what applications that you want in the chroot, by editing the script's APPS value."
echo ""
echo "* Run this script in the directory that you wish to generate the chroot environment in."
echo ""
echo "* This script has only been tested on Ubuntu x86 and CentOS 4 x86_64 - other distributions/arches may require adjustments."
echo ""
echo "Please hit enter once you are ready to begin"
read JUNK


echo "Please enter the user's system name - this is used to generate some of the files:"
read USERNAME
echo "Generating chroot in 5 seconds.... if username is incorrect, hit CTL+C to cancel."
sleep 5



# directories
echo "Building directories...."
mkdir -v etc
mkdir -v bin
mkdir -v lib
mkdir -v lib64
mkdir -v usr
mkdir -v usr/bin
mkdir -vp usr/local/bin
mkdir -vp usr/local/libexec
mkdir -v dev

# creating home directory
echo "Creating home directory..."
mkdir -pv home/$USERNAME
chown $USERNAME:$USERNAME home/$USERNAME
chmod 700 home/$USERNAME

# basic devices
echo "Creating required device nodes..."
mknod -m 0666 dev/null c 1 3
mknod -m 0666 dev/zero c 1 5
mknod -m 0666 dev/tty c 5 0
mknod -m 0644 dev/urandom c 1 9

# For each binary, get all the libraries it requires and copy them across too. :-)
echo "Copying binaries and their depended libraries..."
for prog in $APPS;
do
        cp -v $prog ./$prog

        # obtain a list of related libraries
        ldd $prog > /dev/null
        if [ "$?" = 0 ];
	then
                LIBS=`ldd $prog | awk '{ print $3 }'`
                for lib in $LIBS;
		do
			# work around an error with some 2.6 kernels.
			if [ $lib != '(0xffffe000)' ];
			then
				mkdir -pv ./`dirname $lib` > /dev/null 2>&1
	                        cp -v $lib ./$lib
			fi
                done
        fi
done


# some base libraries
echo "Copying base libraries..."
if [ `uname -m` == "x86_64" ];
then
	cp -v /lib64/ld-linux-x86-64.so.2 /lib64/libnss_compat.so.2 /lib64/libnsl.so.1 /lib64/libnss_files.so.2 ./lib64/
else
	cp -v /lib/ld-linux.so.2 /lib/libnss_compat.so.2 /lib/libnsl.so.1 /lib/libnss_files.so.2 ./lib/
fi


# generate /etc/group and /etc/passwd
echo "Generating /etc/group and /etc/passwd..."
USERID=`id -u $USERNAME`
echo "root:x:0:0::/home/$USERNAME:/bin/bash" >> etc/passwd
echo "root:x:0:" >> etc/group 
echo "$USERNAME:x:$USERID:$USERID::/home/$USERNAME:/bin/bash" >> etc/passwd
echo "$USERNAME:x:$USERID:" >> etc/group 

# generate bash configuration
echo "Generating bash configuration..."
rm -f .bash*
echo "# Generated Configuration"	>> home/$USERNAME/.bash_profile
echo "cd /"				>> home/$USERNAME/.bash_profile
ln -sv home/$USERNAME/.bash_profile .bash_profile


# done
echo "Chroot generated. To make SSH use the user as CHROOT, add a /./home/$USERNAME to the user's home directory in /etc/passwd. Eg: /home/$USERNAME becomes /home/$USERNAME/./home/$USERNAME";
echo ""

