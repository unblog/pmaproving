# pmaproving

This bash script is provisioning phpMyAdmin on GNU/Linux, written in GNU bash v5.1.16(1) on Debian 11 and ran also on Ubuntu 22.04.3 LTS.

## Preface

I wrote `pmaproving.sh` for out-of-the-box use, mainly because deploying phpmyadmin from the Apt repository proved impractical when using different PHP versions, especially in development environments.. I use Apache2 in WSL. To avoid time-consuming setup with every installation and to always provide the same requirements fast and smooth.

## Purpose

Provisioning of phpMyAdmin on your web server always with requirements quick and smooth. Any settings you change in phpMyAdmin are saved, the default setting in the navigation tree is set to Maximum 50 Elements in Branch.

## Usage:

Run in bash as root.

```
cd ~
wget -L https://raw.github.com/unblog/pmaproving/main/pmaproving.sh -O pmaproving.sh
chmod u+x pmaproving.sh
./pmaproving.sh
```

## Requirement

No special requirements are expected; apart of course, a ready-to-use Apache web server with PHP and MariaDB, the unzip and wget packages will be provided automatically if not already exist.

## Addendum

Please leave a comment for suggestions, additions, deviations or troubleshooting.