#!/usr/bin/env bash

yum update -y
yum install httpd -y
chkconfig httpd on
service httpd start

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
