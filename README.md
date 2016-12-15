Containerized Mediawiki
=======================
[![Build Status](http://jenkins.binaryoasis.com/buildStatus/icon?job=mediawiki-docker-stack)](http://jenkins.binaryoasis.com/job/mediawiki-docker-stack/)

###TLDR:
Master is my development (not mw dev). REL branches are inline with their respective (mw) branches

Docker requires a 64-bit OS and version 3.10 or higher of the Linux kernel. To check: uname -r

I recommend running the runfirst.bash. It does work for you with setting visual editor as well as a couple other things. Wiki is on port 80. phpmyadmin is on port 8080. root mysql pw is in the docker-compose.yml. Database host is supposed to be "mysql". It will be preset if you run runfirst.bash


```
You should be on a branch. Check out a branch for the proper instructions 
```

You're now running the world’s largest enterprise wiki platform.

Project Compendium
http://binaryoasis.com:8000


###Known Issues and Todos:
* Architecturally the platform should be sound. There’s basic tests for most of the jenkins jobs, but the whole thing has not undergone extensive testing yet.   
* The nginx ssl portion should be good, but I haven’t been able to toss an ssl in there yet.
* Programmatically things need to be tightened and cleaned. Some of the Jenkins files could use some refactoring and the main bash script is pretty cancerous. My editor likes to unifiy tabs and spaces and not tell me. It shows up in github lol.
* Every once in awhile the database will not give remote permissions to all containers. I think this has to do with at time initialization of mariadb and whether or not name resolution has been completed within docker. I think I resolved this.
* I’ll be adding cassandra and restbase for scalability before too long.


###The Sauce
Installing mediawiki is a bit of a pain (especially with the visual editor). The directions are sometimes unclear on which packages are required for the php compile. At the very least in a platform agnostic manner. As it stands it should work with either debian or redhat based systems that docker supports.


###Why it's better than the mediawiki sponsored docker setup.
The official mediawiki docker image doesn’t really subscribe to the docker ideology. It’s all blob’d into one container. This follows the one service per container concept and is built in a way that that allows for agnostic immutable system setup. I’ll touch on this in the setup section.


Setup
=======================
So obviously there’s going to be assets that need to not be in the container. This is in the distribution files folder. These assets (as well as the containers) are managed by jenkins and are kept up to date with their respective mainline providers. They’ll all be auto mounted pending alternate configuration.


If you want the files to live elsewhere, you can use something like bound mounts.


```
mount -o bind SOURCE DESTINATION
```


This is nice, because now your system can be truly ephemeral and your data can live wherever.


Usage and Common Tasks
=======================
####Starting and Stopping Services


docker stop CONTAINER_NAME; docker start CONTAINER_NAME


####Accessing Daemon Logs


docker logs [ -f ] CONTAINER_NAME


####Accessing a Shell


docker exec -ti CONTAINER_NAME /bin/sh


####Managing the Database


docker exec -ti MYSQL_CONTAINER mysql

Or phpmyadmin:

host:8080


Caveat Emptor
=======================
Per the usual, this is an open source project maintained by some random guy on the internet. Use at your own risk.  


Requirements
------------
Docker && Docker Compose (runfirst.bash will handle this)


Contributing
------------
Let me know if anything is amiss and I’ll fix it.


License and Authors
-------------------
Authors: Ryan Lewkowicz
