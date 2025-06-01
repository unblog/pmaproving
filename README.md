# pmaproving

This bash script provisioning phpMyAdmin on GNU/Linux, written in GNU bash v5.1.16(1) on Debian 11 and ran also with Ubuntu 22.04.3 LTS.

## Preface

I wrote `pmaproving.sh` for out-of-the-box deployment, primarily because deploying phpmyadmin from the Apt repository proved inconvenient and incomplete when used in development environments (I use Apache2 in WSL). This avoids time-consuming setup with each installation and allows you to deploy the same requests quickly and seamlessly every time.

## Purpose

Provisioning of phpMyAdmin on your web server always with requirements quick and smooth. Any settings you change in phpMyAdmin are saved, the default setting in the navigation tree is set to Maximum 50 Elements in Branch, Of course you can increase and decrease the values. You can change settings in the config.inc.php file, or via the small gear in the webUI, these are then saved in the database.

## Usage:

Run in bash as root.

```
cd ~
wget -L https://raw.github.com/unblog/pmaproving/main/pmaproving.sh -O pmaproving.sh
chmod u+x pmaproving.sh
./pmaproving.sh
```
Note. that now is a good opportunity to make your changes in the settings section. You can keep all values ​​as they are, but you should change the password for MYPASS, you'll not need this later; it is only used for database access.

## Requirement

No special requirements are expected; apart of course, a ready-to-use Apache web server with PHP and MariaDB, the unzip and wget packages will be provided automatically if not already exist.

## Addendum

Please leave a comment for suggestions, additions, deviations or troubleshooting.