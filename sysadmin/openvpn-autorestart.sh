#!/bin/bash
#
# Creates a checksum of the /etc/openvpn/*.conf files, and compares them to the checksums
# of the previous day. If the VPN settings have been changed, the checksums won't match and so
# the script restarts openvpn.
#

MD5SUMFILE=/etc/openvpn/autoreboot.lock


# If no md5sum currently exists, we can't do
# anything other than creating the first md5sum
# file
if test -e $MD5SUMFILE;
then
	# md5sum file exists. check it.
	/usr/bin/md5sum -c $MD5SUMFILE >> /dev/null 2>&1
	
	if test $? -ne 0;
	then
		# config has changed. Reload openvpn        
		echo "OpenVPN configuration has changed. Restarted OpenVPN."
		/etc/init.d/openvpn restart
	fi

fi


# create a new checksum file
/usr/bin/md5sum /etc/openvpn/*.conf > $MD5SUMFILE


