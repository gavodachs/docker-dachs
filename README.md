# DaCHS on Docker

Summary

* [How to use it](#how-to-use-it)
* [Using Docker-Compose](#using-docker-compose)

This repository contains the image/dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).

[DaCHS][1] is a suite for managing astronomical data publication through Virtual Observatory (VO)
standards (see [IVOA][2]).

[1]: http://dachs-doc.readthedocs.io
[2]: http://www.ivoa.net

The DaCHS software provides data access services while keeping two daemons running in background,
a DBMS (PostgreSQL) server and the Dachs server itself responsible for the data management
between user interface and database handling.

The [Github][3] repository has three branches, `master`, `dachs`, `postgres`, 
each associated with a different image on [Docker Hub][4].

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/


## How to use it

Docker-Dachs comes in two flavors:
1. the all-in-one image, where gavo-dachs and postgres run together in the same container
1. a pair of images, where gavo-dachs and postgres run separately but linked through a Docker network

First option is provided by `chbrandt/dachs:latest`.
It is exactly what a default install procedure (`apt-get install gavodachs-server`) provides. 
The goal here is to just provide a straight way of having Dachs working on your system 
(Linux, MacOS, Windows).

To run this image, just type:
```

(host)$ docker run -it -p 80:80 chbrandt/dachs:latest

```
Usual Dachs/DB management applies then.

Second option is provided by the images `chbrandt/dachs:server` and `chbrandt/dachs:postgres`. 
This way of running the suite fits better in Docker scenario, where the container is meant to
run _one_ process.

The way you run this images together is like:
```
(host)$ docker run -dt --name postgres chbrandt/dachs:postgres
(host)$ docker run -dt --name dachs --link postgres -p 80:80 chbrandt/dachs:server
```
After a few seconds, after postgres and dachs have initialized, you should see dachs http
interface at `http://localhost`.
If you then to connect to `dachs` container, to manage your data for example, you can type:
```
(host)$ docker exec -it dachs bash
```

This second option, the pair-of-images, can also be run [using Docker-Compose](#using-docker-compose).

`dachs:data` is here to provide a starting point -- it is an example for inserting the data
as volumes into the framework. The contents can be seeing [here, at the Dockerfile][5].

[5]: https://github.com/chbrandt/docker-dachs/tree/master/dockerfile/data

* *Note-1:* the `postgres` container _must_ be named "*postgres*".
* *Note-2:* the `server` container exposes port "*80*".
* *OBS:* the lines below call `dachs:data` just as an example on adding data volumes.

### the Data

Before actually running the (dachs) server, we need to think about the data to be published.
Dachs maintains its datasets under `/var/gavo/inputs`.
There isn't, though, a unique way of doing it with docker; one may prefer to download the 
data from inside the (`dachs`) container from a central repository, for example.

Another way, aligned with Docker "tetris" practices, of inserting data sets into Docker-Dachs
would be through a docker-volume.
Here goes an example on how to do it:
```
(host)$ mkdir -p arihip/data
(host)$ cd arihip && curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd
(host)$ cd data   && curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz
(host)$ cd ../..
(host)$ docker run -d --name arihip -v $PWD/arihip:/var/gavo/inputs/arihip debian
```
Where "`debian`" can be substituted by any other image, as you wish.

And then you could run:
```
(host)$ docker run -it -p 80:80 --volumes-from arihip chbrandt/dachs:latest

# container initiate

[inside container] $ gavo imp arihip/q.rd
[inside container] $ gavo pub arihip/q.rd
[inside container] $ service dachs reload
```

## Using Docker-Compose

The `docker-compose.yml` file assembles all the parameters necessary to run
both containers -- `postgres` and `dachs` -- synchronously.

The [Compose file](https://github.com/chbrandt/docker-dachs/blob/master/docker-compose.yml)
is basically:
```
version: '2'
services:

    dachs:
        container_name: dachs
        image: chbrandt/dachs:server
        tty: true
        network_mode: 'bridge'
        ports:
            - '80:80'
        links:
            - postgres
        depends_on:
            - postgres

    postgres:
        container_name: postgres
        image: chbrandt/dachs:postgres
        tty: true
        network_mode: 'bridge'
```

To run from the compose file, type:
```
# docker-compose up
```

_Any doubt, comment or error, please file an [issue on Github](https://github.com/chbrandt/docker-dachs/issues)_

(Y)
Carlos
