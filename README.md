# DaCHS on Docker

**ToC**
* [Getting started](#getting-started)
  * [Test migration](#test-migration)
    * [DaCHS 2](#dachs-2)

Check the documents directory ([docs/](docs/)) for (practical) notes on 
* [versioning your resources](docs/data_publication.md),
* [persisting data](docs/data_persistence.md), 
* [upgrading DaCHS](docs/upgrade_dachs.md),
* [running dachs and_postgresql individually](docs/individual_containers.md).

---

This repository contains the dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).
You'll find the corresponding images in ['chbrandt/dachs' DockerHub repository][4].
DaCHS (or _suite_) is composed by a Postgres server in the background managed
by the _dachs-server_ which interfaces the database to the user.

The dockerfiles in here will setup image families (with their respective tags):
* `chbrandt/dachs`: DaCHS server + Postgres db -- used for testing only
* `chbrandt/dachs:server`: the DaCHS data-manager/server suite
* `chbrandt/dachs:postgres`: the Postgres db used by DaCHS

In this document we'll see how to run [Dachs-on-Docker][4], the containerized
version of DaCHS.

For detailed information on DaCHS itself or Docker, please
visit their official documentation, [DaCHS/docs][1] or [Docker/docs][2].

> Command-lines running from the _host_ system are prefixed by <b><code>(host)</code></b>;
> And <b><code>(dock)</code></b> are run from inside the container.

[1]: http://dachs-doc.readthedocs.io


# Getting started

> Docker image tags: `latest`,`stable`,`bundle` (and `1`,`1.4`,`all-in-one`)

The "default" -- or `latest`, in Docker jargon -- is composed by _dachs-server_
and _postgresql_.
You run it by mapping the container's port (8080) to some on your host:
```bash
(host)$ docker run -it --name dachs -p 80:8080 chbrandt/dachs
```
, where we mapped the host's port `80` to container's `8080`.
Dachs settings included in this image are in [bundle/etc](dockerfiles/bundle/etc).

Inside the container, to start the services work like in a normal machine:
```bash
(dock)$ service postgresql start
(dock)$ service dachs start
```
. You can also use a convenience `dachs.sh` script to start _postgresql_ for you:
```bash
(dock)$ /dachs.sh start
```

> You can now go to your host's 'http://localhost' to check DaCHS web interface.

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

> If you want to test the services -- dachs-server and postgresql -- running
> separately, check section [DaCHS and PostgreSQL containers][].


## Test migration

If you're using the container to test a new version to eventually migrate your
database, you'll likely want to mount your VO/DaCHS resources as in the example
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

* Docker image tags: `beta`,`2`,`2-beta`

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

This [Github][3] repository has four branches, `master`, `dachs`, `postgres`
and `all-in-one`. Except from `master` each repository is associated with
a different Docker image(/tag) -- `chbrandt/dachs`(`:tag`), available at [Docker Hub][4]:

| git branch | docker tag |
| --- | --- |
| `dachs` | `server` |
| `postgres` | `postgres` |
| `master` | `latest` |

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/
[2]: https://docs.docker.com/


/.\
