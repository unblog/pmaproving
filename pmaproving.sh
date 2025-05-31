#!/bin/bash
#
#    $file:pmaproving.sh created 2025-05-30 12:19 PM CEST
#    $Id:don
#
#    Don Matteo <think@unblog.ch> May 30, 2025.
#    Copyright(c) 2010-2025 A-Enterprise GmbH.
#    https://think.unblog.ch
#
#    Released under the GNU General Public License WITHOUT ANY WARRANTY.
#    See LICENSE.TXT for details.
#
#    vim: expandtab sw=4 ts=4 sts=4:
#
###### SETTINGS ######
MYUSER="pma"
MYPASS="secret123"
DATABASE="phpmyadmin"
source="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip"
### END SETTINGS #####

## PREPARE REQUIREMENTS
if [ ! -f /usr/bin/unzip ]; then
    apt install -y unzip
fi
if [ ! -f /usr/bin/wget ]; then
    apt install -y wget
fi

## GET PHPMYADMIN PACKAGE AND UNPACKING
cd /usr/share
echo "Download $source"
file_name=$(wget -nv -t 20 --content-disposition "$source" 2>&1 | cut -d\" -f2)
echo "unzip $file_name"
unzip -p -C $file_name
echo "Rename ${file_name%????} to phpmyadmin"
mv ${file_name%????} phpmyadmin
rm -f $file_name
chmod -R 0755 phpmyadmin
mkdir /usr/share/phpmyadmin/tmp/
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/

## CREATE APACHE CONFIG
echo "Create Apache phpmyadmin config"

cat << EOF > /etc/apache2/conf-available/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
</Directory>

<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF

a2enconf phpmyadmin
apachectl -t
systemctl reload apache2

## CREATE PHPMYADMIN DATABASE AND USER CREDENTIALS
# If /root/.my.cnf exists then it won't ask for root password
echo "Create phpmyadmin database and grant user access"
if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE ${DATABASE} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${MYUSER}@localhost IDENTIFIED BY '${MYPASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${MYUSER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
    echo "Please enter root user MySQL password!"
    echo "Note: password will be hidden when typing"
    read -sp rootpasswd
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${DATABASE} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${MYUSER}@localhost IDENTIFIED BY '${MYPASS}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${MYUSER}'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi

mysql -uroot phpmyadmin < /usr/share/phpmyadmin/sql/create_tables.sql

# create phpMyAdmin configuration from the saample file in the same way generating the blowfish_secret for cookie auth.
# instead of - cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
# php -r 'echo bin2hex(random_bytes(32)) . PHP_EOL;'

## ADD PHPMYADMIN SETTINGS
# /usr/share/phpmyadmin/config.inc.php

randomBlowfishSecret=$(php -r 'echo bin2hex(random_bytes(32)) . PHP_EOL;')
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = sodium_hex2bin\('$randomBlowfishSecret'\)|" /usr/share/phpmyadmin/config.sample.inc.php > /usr/share/phpmyadmin/config.inc.php

sed -i "/\/\/ \$cfg\['Servers'\]\[\$i\]\['controlpass'\] *= *'pmapass'/ {
    s|^// ||;
    s|'pmapass'|'${MYPASS//&/\\&}'|;
}" /usr/share/phpmyadmin/config.inc.php

sed -i "/\/\/\$cfg\['MaxRows'\] = 50\;/ s#^//##" /usr/share/phpmyadmin/config.inc.php

echo "Provisioning Finish!"
echo "Note. phpMyAdmin using user and password as you set in the settings section."
echo "http://localhost/phpmyadmin/"