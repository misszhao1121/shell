#!/bin/bash
DATE=$( date +%y-%d-%m )
DES=/usr/src/mysql_bak
MYSQL_U="root"
MYSQL_P="root"
MYSQL_H="127.0.0.1"
MYSQL_p="3306"
if [ ! -d "$DES"]; then
	mkdir -p "$DES"
fi

DB=$( mysql -u $MYSQL_U -P$mysql_P -Bse 'show databases' )
for databases in $DB
    do
	if [ ! $database == "information_schema" ]; then
		mysqldump -u $MYSQL_U  -P$mysql_P $databases|bzip2 >"$DES/${DATE}_mysql.gz"
	fi
done

