#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source .env

#system prep
command -v docker >/dev/null 2>&1 || { curl -s https://get.docker.com/ | bash; }
command -v pip >/dev/null 2>&1 || { \curl -L https://bootstrap.pypa.io/get-pip.py | python || \curl -L https://bootstrap.pypa.io/get-pip.py | python3; }
command -v docker-compose >/dev/null 2>&1 || { pip install docker-compose; }
getent passwd www-data >/dev/null 2>&1 || { useradd www-data; }
#I don't want to add OS detection here. These will be on most systems, I think the docker install does curl at the least.
command -v curl >/dev/null 2>&1 || { echo "please install curl and rerun this script"; exit 1; }
command -v wget >/dev/null 2>&1 || { echo "please install wget and rerun this script"; exit 1; }

#Get Software
if [[ -d "$DIR/distribution-files/mediawiki" ]]; then
   printf "\nMediawiki has already been initialized. Please remove $DIR/distribution-files/mediawiki if you would like to reninitialze the platform \n\n"
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

#And again, but now with the extension
MEDIAWIKIREL=$(sed 's/\./_/g' <(echo $MEDIAWIKIVERSION))
#Their website randomly stopped playing nice with curl after working all day. Had to add cruft to make it work.
VEXTENTION=$(curl -s 'https://extdist.wmflabs.org/dist/extensions/' -H 'dnt: 1' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.108 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'cache-control: max-age=0' -H 'authority: extdist.wmflabs.org' --compressed | grep VisualEditor | grep $MEDIAWIKIREL | grep -o \>Visual.*.tar.gz | sed 's/>//g')

wget -qO- https://extdist.wmflabs.org/dist/extensions/$VEXTENTION | tar xvz -C $DIR/distribution-files/mediawiki/extensions/

if [[ $? != 0 ]]; then
  clear
  printf "\nIssue with $VEXTENTION download \n\n"
  exit 1
fi

clear
printf "\nWiki Initialized \n\n"

#Perms
find $DIR/distribution-files/mediawiki -type d -exec chmod 755 {} +
find $DIR/distribution-files/mediawiki -type f -exec chmod 644 {} +
chown -R www-data $DIR/distribution-files/mediawiki

#I don't want to distribute a file anymore. So patching will take place on the fly. VE, mysql host, and Local settings placement will be covered here.

#VE settings
cat > $DIR/tmpfile <<HEREDOC
\$localSettings .= <<<'EOD'

#Pygments
\$wgPygmentizePath = '/usr/local/bin/pygmentize';

#URL OVERRIDE
\$wgScriptPath       = "";
\$wgArticlePath      = "/\$1";
\$wgUsePathInfo      = true;
\$wgScriptExtension  = ".php";

#VISUAL EDITOR

# Enable Visual editor
require_once "\$IP/extensions/VisualEditor/VisualEditor.php";

// Enable by default for everybody
\$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
\$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
\$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

\$wgVirtualRestConfig['modules']['parsoid'] = array(
  // URL to the Parsoid instance
  // Use port 8142 if you use the Debian package
  'url' => 'parsoid:8000',
  'domain' => 'wiki',
  'forwardCookies' => true
);

\$wgSessionsInObjectCache = true;

EOD;

\$file = "/var/www/mediawiki/LocalSettings.php";
if (!file_exists(\$file)) {
  if (is_writable("/var/www/mediawiki/")) {
    \$handle = fopen(\$file, 'w') or die('Cannot open file:  '.\$file);
    fwrite(\$handle, \$localSettings);
  }
}

return \$localSettings;
HEREDOC

sed -i "/return \$localSettings/ {
   r $DIR/tmpfile
   d
 }" $DIR/distribution-files/mediawiki/includes/installer/LocalSettingsGenerator.php
rm $DIR/tmpfile


if [[ $AUTOINSTALL != "false" ]]; then
  docker-compose -f $DIR/autoinstall.yml up -d --force-recreate

  echo "sleeping 15 for mysql init"
  secs=15
  while [ $secs -gt 0 ]; do
     echo -ne "$secs\033[0K\r"
     sleep 1
     : $((secs--))
  done

  docker exec -ti no-one-else-should-be-using-this-name php mediawiki/maintenance/install.php --dbuser="root" --dbpass="$DBPASS" --dbname="$DBNAME" --dbserver="mysql" --installdbuser="root" --installdbpass="$DBPASS" --server="$SERVERURL" --lang=en --pass="$ADMINPASSWORD" "$WIKINAME" "$ADMINUSER"

  docker rm -f no-one-else-should-be-using-this-name
  docker rm -f no-one-else-should-be-using-this-name-or-this

  clear
  printf "\nYour wiki has been created, now you can run:\nmake up \n\n"
fi
