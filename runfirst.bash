#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


command -v docker >/dev/null 2>&1 || { curl -s https://get.docker.com/ | bash; }
curl https://bootstrap.pypa.io/get-pip.py | python
pip install docker-compose
useradd www-data
rm -f $DIR/mediawiki/includes/installer/LocalSettingsGenerator.php
\cp $DIR/distribution-files/LocalSettingsGenerator.php $DIR/distribution-files/mediawiki/includes/installer/LocalSettingsGenerator.php
sed -i "s#wgDBserver.*localhost#wgDBserver \= \'mysql#g" $DIR/distribution-files/mediawiki/includes/DefaultSettings.php
find $DIR/distribution-files/mediawiki -type d -exec chmod 755 {} +
find $DIR/distribution-files/mediawiki -type f -exec chmod 644 {} +
chown -R www-data.www-data $DIR/distribution-files/mediawiki
