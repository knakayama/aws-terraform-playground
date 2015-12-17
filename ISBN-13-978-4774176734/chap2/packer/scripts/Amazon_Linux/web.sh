#!/usr/bin/env bash

yum install nginx -y
service nginx start
chkconfig nginx on
yum install mysql-server -y
service mysqld start
chkconfig mysqld on
yum groupinstall "Development Tools" -y
yum install ruby-devel mysql-devel -y
yum install nodejs -y --enablerepo=epel
gem install rails io-console --no-rdoc --no-ri
rails new my-app \
  --database=mysql \
  --skip-git \
  --skip-javascript \
  --skip-spring \
  --skip-test-unit
cd my-app
echo "gem 'io-console'" >> Gemfile
bundle install
rails generate scaffold book name:string price:decimal
rake db:create
rake db:migrate
rails server -b 0.0.0.0

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=sh sw=2 ts=2 et
