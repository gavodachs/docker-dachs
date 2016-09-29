# DaCHS on Docker

This repository contains the image/dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).

[DaCHS][1] is a suite for managing astronomical data publication through Virtual Observatory (VO) 
standards (see [IVOA][2]).

[1]: http://dachs-doc.readthedocs.io
[2]: http://www.ivoa.net

The DaCHS software provides data access services while keeping two daemons running in background, 
a DBMS (PostgreSQL) server and the Dachs server itself responsible for the data management 
between user interface and database handling.

The [Github][3] repository has three branches, `master`, `dachs`, `postgres`, hosting four 
dockerfiles, each associated with a different image on [Docker Hub][4].

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/

While the `master` branch provides the "default" -- `latest` -- image, containing the all-in-one 
package (dachs + postgres), the other branches `dachs` and `postgres` provide the respective 
servers on their own.
The `master` branch has _two_ dockerfiles actually: the one inside `data/` is a dataset example, 
also individually built.

## How to use it

`dachs:server` and `dachs:postgres` are the "main" images -- meaning the ones it is believed to 
provide a better use of Dachs and Docker.

`dachs:latest` is exactly what a default install procedure would provide to user on his/her own 
bare machine.

`dachs:data` is here to provide a starting point -- it is an example for inserting the data 
as volumes into the framework. The contents can be seeing [here, at the Dockerfile][5].

[5]: https://github.com/chbrandt/docker-dachs/tree/master/dockerfile/data

* *Note-1:* the `postgres` container _must_ be named "*postgres*".
* *Note-2:* the `server` container exposes port "*80*".
* *OBS:* the lines below call `dachs:data` just as an example on adding data volumes.

### the Data

Before actually running the (dachs) server, we need to think about the data to be used.
Dachs maintains its datasets under `/var/gavo/inputs`; we should then provide the data and
its respective Resource Descriptor accordingly.

The lines below provide an example on how to create such `data-volume` to be used by `dachs`:
```
$ mkdir -p arihip/data
$ cd arihip && curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd
$ cd data   && curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz
$ cd ../..
$ docker run -d --name arihip -v $PWD/arihip:/var/gavo/inputs/arihip debian
```
Where "`debian`" can be substituted by any other image, but since this is the base
image of all the images being dealt here, it is convenient to use it.

The exactly same `volume` is provided by `$ docker run -d --name arihip chbrandt/dachs:data`.

### the Servers
After dealing with the data to be used by Dachs, we can effectively start the "main" containers:
```
$ docker run -dt --name postgres chbrandt/dachs:postgres
$ docker run -it --name dachs --link postgres --volumes-from arihip -p 80:80 chbrandt/dachs:server
```
Notice that any number of volumes -- here only "arihip" was used -- can be mounted.

After doing so a command line from inside the `dachs:server` container will show up.
Now, usual gavo/dachs maintainance tasks apply.
For instance, to see the "arihip" data on your browser's `http://localhost:8080`, you'd go through:
```
[inside docker] $ gavo imp arihip/q.rd
[inside docker] $ gavo pub arihip/q.rd
[inside docker] $ service dachs reload
```

That should work. You should now see ARIHIP data at `http://localhost:8080`.

_Any doubt, comment or error, please file an [issue on Github](https://github.com/chbrandt/docker-dachs/issues)_

(Y)
Carlos
