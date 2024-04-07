#!/bin/bash

HOSTNAME="xyz"
MYSQL_DB_NAME="traccardb"
MYSQL_ROOT_USER="admin"
MYSQL_ROOT_PASSWORD="admin123"
MYSQL_USER="testusr"
MYSQL_PASSWORD="strongpass123"

sudo mysql -h $HOSTNAME -u $MYSQL_ROOT_USER -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
SET GLOBAL time_zone = '+05:30';
CREATE DATABASE IF NOT EXISTS $MYSQL_DB_NAME;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# sed -i 's/^bind-address\s*=.*/bind-address = PRIVATE_IP_OF_EC2/' /etc/mysql/mysql.conf.d/mysqld.cnf

# service mysql restart

echo "MySQL configuration completed."