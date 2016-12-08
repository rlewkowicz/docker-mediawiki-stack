#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

command -v docker >/dev/null 2>&1 || { curl -s https://get.docker.com/ | bash; }
service docker start
command -v pip >/dev/null 2>&1 || { \curl -L https://bootstrap.pypa.io/get-pip.py | python || \curl -L https://bootstrap.pypa.io/get-pip.py | python3; }
command -v docker-compose >/dev/null 2>&1 || { pip install docker-compose; }
getent passwd www-data >/dev/null 2>&1 || { useradd www-data; }
rm -f $DIR/mediawiki/includes/installer/LocalSettingsGenerator.php
\cp $DIR/distribution-files/LocalSettingsGenerator.php $DIR/distribution-files/mwcore/mediawiki/includes/installer/LocalSettingsGenerator.php
sed -i "s#wgDBserver.*localhost#wgDBserver \= \'mysql#g" $DIR/distribution-files/mwcore/mediawiki/includes/DefaultSettings.php
find $DIR/distribution-files/mwcore/mediawiki -type d -exec chmod 755 {} +
find $DIR/distribution-files/mwcore/mediawiki -type f -exec chmod 644 {} +
chown -R www-data.www-data $DIR/distribution-files/mwcore/mediawiki
