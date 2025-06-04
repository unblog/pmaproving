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
#################### SETTINGS ####################
## Note. default userid 'pma' to database access #
MYUSER="pma" # USERID TO ACCESS DATABASE PHMYADMIN
MYPASS="secret123" # USER PASSWORD ACCESS DATABASE
DATABASE="phpmyadmin" # TO CREATE DEFAULT DATABASE
SOURCE="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip"
################## END SETTINGS ##################

## PREPARE REQUIREMENTS
if [ ! -f /usr/bin/unzip ]; then
    apt install -y unzip
fi
if [ ! -f /usr/bin/wget ]; then
    apt install -y wget
fi
## DOWNLOAD PACKAGE AND UNPACKING
# Note. I ran wget like this because I suspect that the file name could change at some point!
cd /usr/share
echo "Download $SOURCE"
file_name=$(wget -nv -t 20 --content-disposition "$SOURCE"  2>&1 | cut -d\" -f2)
echo "Unshrink $file_name"
unzip -q -C $file_name
echo "Rename ${file_name%????} phpmyadmin"
mv ${file_name%????} phpmyadmin
rm -f $file_name
chmod -R 0755 phpmyadmin
mkdir /usr/share/phpmyadmin/tmp/
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/

## CREATE APACHE CONFIG
echo "Create Apache phpmyadmin"
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

apachectl -t
a2enconf phpmyadmin
systemctl reload apache2

## CREATE DATABASE AND USER CREDENTIALS
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
# create SQL tables
mysql -uroot phpmyadmin < /usr/share/phpmyadmin/sql/create_tables.sql

# create phpMyAdmin configuration from the saample file in the same way generating the blowfish_secret for cookie auth.
# actually cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
# php -r 'echo bin2hex(random_bytes(32)) . PHP_EOL;'
## ADD BLOWFISH SECRET
randomBlowfishSecret=$(php -r 'echo bin2hex(random_bytes(32)) . PHP_EOL;')
sed -e "s|cfg\['blowfish_secret'\] = ''|cfg['blowfish_secret'] = sodium_hex2bin\('$randomBlowfishSecret'\)|" /usr/share/phpmyadmin/config.sample.inc.php > /usr/share/phpmyadmin/config.inc.php
## ADD SECRET TO CONFIG
sed -i "/\/\/ \$cfg\['Servers'\]\[\$i\]\['controlpass'\] *= *'pmapass'/ {
    s|^// ||;
    s|'pmapass'|'${MYPASS//&/\\&}'|;
}" /usr/share/phpmyadmin/config.inc.php
## CHANGE MAX ROWS
sed -i "/\/\/\$cfg\['MaxRows'\] = 50\;/ s#^//##" /usr/share/phpmyadmin/config.inc.php
# done
echo "Provisioning Finish!"
echo "Note. phpMyAdmin sign in using user and secret as you set in MariaDB."
echo "http://localhost/phpmyadmin/"