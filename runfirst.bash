#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MEDIAWIKIVERSION="1.27"

#system prep
command -v docker >/dev/null 2>&1 || { curl -s https://get.docker.com/ | bash; }
command -v pip >/dev/null 2>&1 || { \curl -L https://bootstrap.pypa.io/get-pip.py | python || \curl -L https://bootstrap.pypa.io/get-pip.py | python3; }
command -v docker-compose >/dev/null 2>&1 || { pip install docker-compose; }
getent passwd www-data >/dev/null 2>&1 || { useradd www-data; }

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
VEXTENTION=$(curl -s https://extdist.wmflabs.org/dist/extensions/ | grep VisualEditor | grep $MEDIAWIKIREL | grep -o \>Visual.*.tar.gz | sed 's/>//g')

wget -qO- https://extdist.wmflabs.org/dist/extensions/$VEXTENTION | tar xvz -C $DIR/distribution-files/mediawiki/extensions/

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
