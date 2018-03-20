Containerized Mediawiki
=======================
[![Build Status](http://jenkins.binaryoasis.com/buildStatus/icon?job=mediawiki-docker-stack)](http://jenkins.binaryoasis.com/job/mediawiki-docker-stack/)

Project Compendium: http://binaryoasis.com:8000 (Not quite reflective of the rebuild)

## Freshly re-engineered!
I just rebuilt everything to be a little less static. The upside is it's easier to pick your version and I have a lot less to maintain, the down side is that it's a little less "wow" factor and probably more prone to code rot. Still better than just time/feature rot I suppose.

## Whats Changed?

* PHP and Parsoid are now runtime builds
* These builds are now located in this repo at docker-mediawiki-build
* Wiki initialization can be programmatic via environment variables

The PHP image is based on laradock's php (Like, pretty aggressively. I added a few things, but I need to go trim the fat). The build file is for PHP 7.2. This shouldn't be a problem for mediawiki core, I think they backported 7.2 support to the 27 branch but don't quote me on that. If you run into issues open a bug and I can fix it a lot quicker now that I adopted (poached?) laradocks build structure. Or feel free to go grab a build file right from laradock and submit a pull after the needed adjustments.

## Auto install and setting your version
In the runfirst.bash file, there is a series of variables that are pretty self explanatory. AUTOINSTALL can be set to anything other than "false" and it will do the auto install. You could set it to "banana", and it would work. In fact, I hope you do. If you have not yet built your PHP image, it will build it at that time.

## Gotchas and stuff to be aware of
First, if you do a manual install just remmber the host for mysql is the service name in compose, so "mysql" is the host when prompted. Also, you may want to change the password in the compose file.

The old version of this repo was nice because everything was pre built and you knew it would work. It's worked for the last year without me touching it. This is a bit more of a who knows? Did parsoid get updated, did the "localsettings" variable get changed? Does version X of VE or Mediawiki play nice with PHP version Y? This is always going to grab updated code though, and it's all prepackaged by mediawiki. It's easier to maintain and update and with any luck people will join in and we can build a nice little project around this.

At the time of this writing, I just finished it and there was pretty much just a smoke test. I spun it up with and without auto install and made an edit. I fixed in the old wiki an issue with too many people using visual editor. I think if I recall it was tying up PHP connections or something. I have yet to look fully into the laradock (what this is now based off of) configurations.

## Contributions
It's all right here in this repo now. Easy to access, easy to maintain. The only file modifications I make are now handled by runfirst.bash, and a little HEREDOC. The PHP build file is just a laradock file with git, pygments, and composer installed. If you have better bash-isms or cleaner structuring (which shouldn't be to hard given the current state :P) fork, adjust as desired, submit a pull.
