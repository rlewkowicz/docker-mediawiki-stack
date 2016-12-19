Containerized Mediawiki
=======================
[![Build Status](http://jenkins.binaryoasis.com/buildStatus/icon?job=mediawiki-docker-stack)](http://jenkins.binaryoasis.com/job/mediawiki-docker-stack/)

#READ THIS:
So mediawiki is a lot like hearding cats. There's a lot of little pieces moving around, and bringing it together in an agnostic way thus far is impossible. Mediawiki was not made with docker in mind so there's caveats here and there to be aware of. For parsoid and nginx you should really set your hostname (uri). Also, you should be using a deployment platform of some sort (chef/chef solo, ansible, salt, puppet, some other cool thing I don't know about) to deploy this (Unless you're just looking for the core platform, then no biggie). I'd say that the containers are production ready, some of the confs may not be. There's still a lot of shuffle going on in this project.  

##Known Issues and Todos:
* My Jenkins Jobs are all outta wack. I need to do readme templetes and jobs to update them. A couple of them need to be setup for multi branch. 
* I added restbase. Looks like they have it as an entry point in their diagram. Mine's like sideloaded. I don't know if it's working as intended yet. 
* I did sub module mediawiki. It was a good call. It's nice to manage it independently. 


###TLDR:
Master is my development (not mw dev). REL branches are inline with their respective (mw) branches

Docker requires a 64-bit OS and version 3.10 or higher of the Linux kernel. To check: uname -r

I recommend running the runfirst.bash. It does work for you with setting visual editor as well as a couple other things. Wiki is on port 80. phpmyadmin is on port 8080. root mysql pw is in the docker-compose.yml. Database host is supposed to be "mysql". It will be preset if you run runfirst.bash


```
You should be on a branch. Check out a branch for the proper instructions. Otherwise this has a RESTbase setup, but idk if it's getting used properly
```

You're now running the world’s largest enterprise wiki platform.

Project Compendium
http://binaryoasis.com:8000



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
