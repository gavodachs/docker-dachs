# DaCHS on Docker

This repository contains the files for encapsulating [GAVO DaCHS](http://docs.g-vo.org/DaCHS/)
in Docker containers.
You'll find the corresponding images in ['chbrandt/dachs'][4] DockerHub repository.

![](https://img.shields.io/docker/v/chbrandt/dachs/2.1?label=DaCHS%20%28latest%29&style=for-the-badge)

[![Build Status](https://travis-ci.org/gavodachs/docker-dachs.svg?branch=master)](https://travis-ci.org/gavodachs/docker-dachs)

**ToC**
* [Getting started](#getting-started)
  * [Test migration](#test-migration)
    * [DaCHS 2](#dachs-2)

Check the documents directory ([docs/](docs/)) for (practical) notes on
* [versioning your resources](docs/data_publication.md),
* [persisting data](docs/data_persistence.md),
* [upgrading DaCHS](docs/upgrade_dachs.md),
* [running dachs and postgresql individually](docs/individual_containers.md).

#### Note on DaCHS versions

**Notice** that DaCHS is currently maintained under two versions, the good-old `v1.x`
(`v1.4` as of July/2020) running on Python-2, and the new `v2.x` series (Python-3).
The _beta_ period for version-2 is gone, but you may find some residuals in the
following docs; _Please, let me know if something doesn't fit in_.

> By all means, for those coming here looking for a test bed to test the eventual
> upgrade of their DBMS, you may find sections [Test migration](#test-migration)
> and [DaCHS 2](#dachs-2) helpful.


---

DaCHS -- the service -- is composed by two daemons: PostgreSQL and the DaCHS
server itself. Postgres stores the data, whereas DaCHS-server interfaces the
data-store and the user and everything related to [Virtual Observatory](http://ivoa.net/).

If you dig into the files and dockerfiles of this repo you'll find out three
Docker containers being defined out this repo, which ultimately are defining
the containers `chbrandt/dachs`, `chbrandt/dachs:server`, `chbrandt/dachs:postgres`.

> **If you're new to DaCHS and Docker don't worry too much and focus on `chbrandt/dachs`**
> **container. Or all you want is to have a DaCHS instance running in _no time_,**
> **quick and easy, you too just focus on `chbrandt/dachs` container.**

The dockerfiles in here will setup image families (with their respective tags):
* `chbrandt/dachs`: DaCHS server + Postgres db -- the quickest way to action
  * can be called the **_recommended_** container
* `chbrandt/dachs:server`: the DaCHS data-manager/server suite
* `chbrandt/dachs:postgres`: the Postgres db used by DaCHS

In this document we'll see how to run [Dachs-on-Docker][4].

For detailed information on DaCHS itself or Docker, please
visit their official documentation, [DaCHS/docs][1] or [Docker/docs][2].

> Command-lines running from the _host_ system are prefixed by <b><code>(host)</code></b>;
> And <b><code>(dock)</code></b> are run from inside the container.

[1]: http://dachs-doc.readthedocs.io


# Getting started

## `chbrandt/dachs`

The `latest` (Docker) image provides the (DaCHS) service as a whole, encapsulating
dachs-server _and_ postgresql dbms in the same container.

By default, DaCHS provides an HTML/GUI interface at port `8080`, on running the
container you want to _map_ the container's port (8080) to some on the host:
```bash
(host)$ docker run -it --name dachs -p 8080:8080 chbrandt/dachs
```
, where we made an identity map (host's `8080` to container's `8080`).

Inside the container, to start the services work like in a normal machine:
```bash
(dock)$ service postgresql start
(dock)$ service dachs start
```
. You can also use a convenience `dachs.sh` script to start _everything_ for you:
```bash
(dock)$ /dachs.sh start
```

> Go to your host's 'http://localhost:8080' to check DaCHS front-page.

To make a directory from the host system available from the container one can
use the option argument '`-v`' to _mount_ a _volume_ at given location inside
the container:
```bash
(host)$ docker run -it --name dachs -p 80:8080 \
                   -v /data/inputs/resourceX:/var/gavo/inputs/resourceX \
                   chbrandt/dachs
```
You can mount as many volumes (directories) as you want.

Inside the container, you can use _dachs_ as you would on an usual machine.
For instance, run DaCHS and load/pub "resourceX":
```bash
(dock)$ service postgresql start
(dock)$ service dachs start
(dock)$
(dock)$ cd /var/gavo/inputs
(dock)$ gavo imp resourceX/q.rd
(dock)$ gavo pub resourceX/q.rd
(dock)$
(dock)$ service dachs reload
```

## Test migration

If you're using the container to test a new version to eventually migrate your
datasets to, you'll likely want to mount your VO/DaCHS resources as in the example
above. To add security to your data -- if they are being shared with the data
resource live in production -- you may want to use '`ro`' (_read-only_) as an
option for mounting points:
```bash
(host)$ docker run -v /data/rd/input:/var/gavo/inputs/input:ro \
                   -it --name dachs -p 80:8080 \
                   chbrandt/dachs
```

And then do the _imports_, _publications_, data access tests necessary to check
for compatibility; and eventually migrate to the new version if/when everything is fine.


### DaCHS 2

* Docker image tags: `latest`, `2.1` (previously, `beta`)

DaCHS' version 2 is available as a beta version, which runs on Python-3.
Because it is a major upgrade _dachs_ has gone through, it is a good idea to test
your data and services as extensively as possible.

To use the new version, just have to use the `beta` image:
```bash
(host)$ docker run -v /data/rd/input:/var/gavo/inputs/input:ro \
                   -it --name dachs -p 80:8080 \
                   chbrandt/dachs:beta
```

Everything should feel the same.
Start docker (here through the convenience script left in your container's '`/`'),
and use/test it as usual:
```bash
(dock)$ /dachs.sh start
9.6/main (port 5432): down
[ ok ] Starting PostgreSQL 9.6 database server: main.
[ ok ] Starting VO server: dachs.
(dock)$
(dock)$ dachs --version
Software (2.0.4) Schema (23/23)
```

## This repository structure

This [Github][3] repository has four branches, `master`, `dachs`, `postgres`.
The `master` branch has the Dockerfile for the `latest` (aka, _bundle_) docker image.
The others, `dachs` and `postgres` have the Dockerfiles for the individual containers.

DaCHS-on-Docker _image:tag_ sets for `chbrandt/dachs`,  available at [Docker Hub][4]:

| git branch | docker image |
| --- | --- |
| `master` | `chbrandt/dachs:latest` |
| `dachs` | `chbrandt/dachs:server` |
| `postgres` | `chbrandt/dachs:postgres` |

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/
[2]: https://docs.docker.com/


/.\
