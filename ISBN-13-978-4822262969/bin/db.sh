#!/usr/bin/env bash

sudo yum install mysql-server -y
sudo chkconfig mysqld on
sudo service mysqld start
mysql -uroot -e \
  "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot -e \
  "GRANT ALL on wordpress.* to wordpress@'%' identified by 'wordpress'"
sudo mysqladmin flush-privileges

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
