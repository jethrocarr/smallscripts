#!/bin/sh
#
# postgresql_customdumpall.sh
#
# Script that gets a list of all the postgresql databases, and exports them individually
# in custom format.
#
# Original written by Blair Zajac <blair at orcaware.com>
# Modified by Jethro Carr <jethro.carr@jethrocarr.com>
#

# Postgresql username.
pg_username="postgres"

# Directory where backups go.
backup_dir="/var/lib/pgsql/backups/"


do_backup()
{
	database=$1
	shift

 	filename=$1
	shift

	if [ "$database" == 'template0' ] ;
	then
		echo "SKIPPING DB $database"
		return 0
	fi

	if [ "$database" == 'template1' ] ;
	then
		echo "SKIPPING DB $database"
		return 0
	fi

	if [ "$database" == 'postgres' ] ;
	then
		echo "SKIPPING DB $database"
		return 0
	fi


	echo "  backing up $database"

	test -e $filename.dump && rm -f $filename.dump
	/usr/bin/pg_dump -Fc -c --oids --compress 9 -f $filename.dump $database

	if test $? -ne 0; then
		echo "$0: pg_dump failed." 2>&1
		return 1
	fi

	return 0
}

if test ! -d "$backup_dir"; then
  echo "$0: backup directory '$backup_dir' does not exist or is not a dir" 1>&2
  exit 1
fi

# All backups need to be done as the postgres user. Check if we are running
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

# Get the list of databases.
pg_databases="`/usr/bin/psql -l \
  | awk 'NF == 5 && \
     $1 != "Name" && \
     $1 != "template0" && \
     $2 == "|" && \
     $3 != "Owner" && \
     $4 == "|" && \
     $5 != "Encoding" \
     {print $1}' \
  | sort`"

umask 0077
cd $backup_dir || exit 1


echo "$0: backing up postgresql database"

status=0
for db in $pg_databases; do
	do_backup $db $db
	if test $? -ne 0; then
		status=1
	fi
done

if test 0 -eq "$status"; then
	echo "$0: backup of postgresql succeeded"
	exit 0
else
	echo "$0: backup of postgresql FAILED" 1>&2
	exit 1
fi

