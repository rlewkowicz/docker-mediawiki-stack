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

## Doot
