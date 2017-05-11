#!/bin/bash

#Update repo
apt-get update

#Generate mysql password
MYSQL_ROOT_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w8 | head -n1)

#Set the password so you don't have to enter it during installation
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

#Tools
apt-get install htop vim nano -y

#Main install
apt-get install mysql-server mysql-client apache2 php5 php5-cli libapache2-mod-php5 php5-mysql php5-memcached php5-curl php5-gd php-pear php5-imagick php5-mcrypt php5-mhash php5-sqlite php5-xmlrpc php5-xsl php5-json php5-dev libpcre3-dev make sed -y

#Finding absolute path to opcache.so location on Debian
#OPCODE_EXTENSION_VAR=$(find / -name opcache.so)

read -p "Install APCU PHP Exention (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  #Zend OpCache and APCu
  printf "\n" | pecl install apcu

  #Enable apcu ext
  sed -i "2i\extension=apcu.so" /etc/php5/apache2/php.ini
  sed -i "4i\opcache.max_accelerated_files=30000" /etc/php5/apache2/php.ini
  sed -i "5i\opcache.memory_consumption=160" /etc/php5/apache2/php.ini
  sed -i "6i\opcache.revalidate_freq=0" /etc/php5/apache2/php.ini
fi

service apache2 restart

#Create info file
echo "<?php phpinfo();" > /var/www/html/info.php

echo "---- Installation completed ----"
echo "Your PHP Version is:"
php -v
echo "---"
echo "Your MySQL root password is:"
echo $MYSQL_ROOT_PASSWORD
