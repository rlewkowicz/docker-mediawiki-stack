#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MEDIAWIKIVERSION="1.29"

#system prep
command -v docker >/dev/null 2>&1 || { curl -s https://get.docker.com/ | bash; }
command -v pip >/dev/null 2>&1 || { \curl -L https://bootstrap.pypa.io/get-pip.py | python || \curl -L https://bootstrap.pypa.io/get-pip.py | python3; }
command -v docker-compose >/dev/null 2>&1 || { pip install docker-compose; }
getent passwd www-data >/dev/null 2>&1 || { useradd www-data; }

#Get Software
if [[ -d "$DIR/distribution-files/mediawiki" ]]; then
   echo "Mediawiki has already been initialized. Please remove $DIR/distribution-files/mediawiki if you would like to reninitialze the platform" 
   echo
   exit 1
fi

#I'm not a hugefan of this nasty bash block, but I don't want to get into crazy awkisms and
#They don't provide a real nice way to just grab a latest release thats not nightly
MEDIAWIKISEMVAR=$(curl -s https://releases.wikimedia.org/mediawiki/$MEDIAWIKIVERSION/ | grep -o \<.*[0-9]*\-[0-9]*\-[0-9]* \
| grep -v sig | grep -v core | grep -v '\-rc' | grep tar.gz \
| awk '{print $7, $6}' | sort -rn | head -1 \
| grep -o \>mediawiki-.*.tar.gz | sed 's/>//g')

wget -qO- https://releases.wikimedia.org/mediawiki/$MEDIAWIKIVERSION/$MEDIAWIKISEMVAR | tar xvz -C $DIR/distribution-files/

mv $DIR/distribution-files/$(sed 's/.tar.gz//g' <(echo $MEDIAWIKISEMVAR)) $DIR/distribution-files/mediawiki



find $DIR/distribution-files/mediawiki -type d -exec chmod 755 {} +
find $DIR/distribution-files/mediawiki -type f -exec chmod 644 {} +
chown -R www-data $DIR/distribution-files/mediawiki
