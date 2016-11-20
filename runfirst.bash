if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


curl -s https://get.docker.com/ | bash
python -m ensurepip
pip install docker-compose
useradd www-data
yes | cp -rf $DIR/distribution-files/LocalSettingsGenerator.php $DIR/mediawiki/includes/installer/LocalSettingsGenerator.php
find $DIR/distribution-files/mediawiki -type d -exec chmod 755 {} +
find $DIR/distribution-files/mediawiki -type f -exec chmod 644 {} +
