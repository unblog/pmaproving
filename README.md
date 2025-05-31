# pmaproving

This bash script is provisioning phpMyAdmin on GNU/Linux, written in GNU bash v5.1.16(1) on Debian 11 and Ubuntu 22.04.3 LTS.

## Preface

I wrote `pmaproving.sh` primarily because deploying phpmyadmin from the apt repository proved impractical when using different PHP versions, especially in development environments. I use Apache2 in WSL. To avoid time-consuming setup with every installation and to always provide the same requirements quickly and smouth, I created this Bash script.

## Purpose

Provisioning of phpMyAdmin on your web server always with requirements quickly and smouth.

## Usage:

Run in bash as root.

```
cd ~
wget -L https://raw.github.com/unblog/pmaproving/main/pmaproving.sh -O pmaproving.sh
chmod 755 pmaproving.sh
./pmaproving.sh
```

## Requirement

No special requirements are expected; Apart from that, a ready-to-use web server with Apache and PHP, the unzip and wget packages will be provided automatically if not already exist.

## Addendum

Please leave a comment for suggestions, additions, deviations or troubleshooting.