# DaCHS on Docker

This repository contains the image/dockerfiles for GAVO DaCHS.

[DaCHS](http://dachs-doc.readthedocs.io) is a suite for managing
astronomical data publication through Virtual Observatory (VO)
standards (see [IVOA](http://www.ivoa.net)).

The DaCHS software provides data access services while keeping
two daemons running in background, a DBMS (PostgreSQL) server
and the Dachs server itself responsible for the data management
between user interface and database handling.

The [Github](https://github.com/chbrandt/docker-dachs) repository
has three branches, `master`, `dachs`, `postgres`, hosting
four dockerfiles, each associated with a different image on
[Docker Hub](https://hub.docker.com/r/chbrandt/dachs/).

While the `master` branch provides the "default" -- `latest` --
image, containing the all-in-one package (dachs + postgres),
the other branches `dachs` and `postgres` provide the respective
servers on their own.
The `master` branch has _two_ dockerfiles actually: the one
inside `data/` is a dataset example, also individually built.

## How to use it

As said, the "main" images -- meaning the ones it is believed to
provide a better use of Dachs and Docker -- are `dachs:server` and
`dachs:postgres` tags. `dachs:latest` is exactly what a default
install procedure would provide to user on his/her own bare machine.
`dachs:data` is here to provide a starting point, the user is
encouraged to read the respective Dockerfile.

* *Note-1:* the `postgres` container _must_ be named "postgres".
* *Note-2:* the `server` container exposes port "8080".
* *OBS:* lines below call `dachs:data` as an example for adding volumes.

```
$ docker run -d --name arihip chbrandt/dachs:data
$ docker run -dt --name postgres chbrandt/dachs:postgres
$ docker run -it --name dachs --link postgres --volumes-from arihip \
                 -p 8080:8080 chbrandt/dachs:server
```

_Any doubt, error or comment, please file a [issue on Github]
(https://github.com/chbrandt/docker-dachs/issues)_

(Y)
Carlos
