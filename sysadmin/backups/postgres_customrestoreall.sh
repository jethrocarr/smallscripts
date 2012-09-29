#!/bin/sh
#
# postgresql_customdumpall.sh
#
# Script that restores all the *.dump files in a particular location into the database
#
# Written by Jethro Carr <jethro.carr@jethrocarr.com>
# Based on postgres dump script by Blair Zajac <blair at orcaware.com>
#

# Postgresql username.
pg_username="postgres"

# directory to get the dumps from
restore_dir="/var/lib/pgsql/backups/"


do_restore()
{
	database=$1
	shift

 	filename=$1
	shift

	echo "  restoring $database"

	if test -e $filename; then

		/usr/bin/pg_restore -Fc -c -d $database $filename

		if test $? -ne 0; then
			echo "$0: pg_restore failed." 2>&1
			return 1
		fi
	else
		echo "$filename file does not exist.." 2>&1
		return 1
	fi
		

	return 0
}

if test ! -d "$restore_dir"; then
  echo "$0: restore directory '$restore_dir' does not exist or is not a dir" 1>&2
  exit 1
fi

# All restores need to be done as the postgres user. Check if we are running
# as the postgres user, and if not, su into the postgres user.
pg_uid="`/bin/grep ^$pg_username /etc/passwd | /usr/bin/cut -d: -f3`"
if test -z "$pg_uid"; then
	echo "$0: unable to determine postgresql user '$pg_username' uid." 1>&2
 	exit 1
fi

my_uid="`/usr/bin/id -u`"
if test -z "$my_uid"; then
	echo "$0: unable to determine my effective uid." 1>&2
	exit 1
fi

case "$my_uid" in
	0)
		exec /bin/su - $pg_username -c "$0"
	;;
	$pg_uid)
	;;
	*)
		echo "$0: must run this as root or $pg_username"
		exit 1
	;;
esac

umask 0077
cd $restore_dir || exit 1

# get the list of dbs to restore
pg_databases="`ls -1 | sort | sed s/.dump//`"


echo "$0: restoring postgresql database"

status=0
for db in $pg_databases; do
	do_restore $db $db.dump
	if test $? -ne 0; then
		status=1
	fi
done

if test 0 -eq "$status"; then
	echo "$0: restore of postgresql succeeded"
	exit 0
else
	echo "$0: restore of postgresql FAILED" 1>&2
	exit 1
fi

