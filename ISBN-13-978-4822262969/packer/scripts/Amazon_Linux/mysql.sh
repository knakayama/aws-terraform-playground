#!/usr/bin/env bash

yum install mysql-server -y
chkconfig mysqld on
service mysqld start
mysql -uroot -e \
  "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot -e \
  "GRANT ALL on wordpress.* to wordpress@'%' identified by 'wordpress'"
mysqladmin flush-privileges

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
