# DaCHS on Docker

[![Build Status](https://travis-ci.com/gavodachs/docker-dachs.svg?branch=master)](https://travis-ci.com/gavodachs/docker-dachs)

> ###### NOTE:
> Recently, the Dachs-on-Docker images repository -- on DockerHub -- have been
> changed from `chbrandt` to `gavodachs`repository.
> The documentation is being reviewed and updated accordingly, but if/whenever
> you see a `chbrandt/dachs`, read, change it to `gavodachs/dachs`.

Here you'll find recipes for build and running [GAVO DaCHS](http://docs.g-vo.org/DaCHS/)
in Docker containers.

These files build the images available in DockerHub's ['gavodachs'][gavodachs] repository.

[gavodachs]: https://hub.docker.com/u/gavodachs


## Quick Dachs
DaCHS _service_ is composed by two daemons: PostgreSQL and the Dachs the _server_.
Postgres stores the data, while Dachs-server interfaces the user (web, api) and
manages the astro/planetary data accordingly.
By default, Dachs provides its (api) endpoints at port `8080` on `localhost`.

> For fine details about DaCHS, refer to the official docs: https://soft.g-vo.org/dachs.

### Run it
If all you wanna do now is to run _Dachs-on-Docker_ , run the following:

```bash
[~/docker-dachs]$ docker run -it -p 8080:8080 --name dachs gavodachs/dachs

# some initialization output (...)

[root@10dd4547e]$ /dachs.sh start
```

First command will instantiate the container and provide you a
bash session from inside the container.
The second line then start Postgres and Dachs server.

> If you go to [http://localhost:8080](http://localhost:8080) now, 
> you should be able to
> see an empty -- but working -- Dachs service web page.


### Docker Images
The containers are built using Debian Bullseye and GAVO repositories, see
[`apt_sources.list`](dockerfiles/dachs/etc/apt_sources.list).
When building the [dockerfiles/images](dockerfiles/) the (apt) repository(ies)
to use can be specified.
Go to [dockerfiles/README.md](dockerfiles/README.md) for specifics on building 
and composing containers.

> The `latest` containers include _all_ (apt) repositories: Debian main/backports, and GAVO release/beta (providing the _latest_ version of Dachs).

There are three images -- `dachs`, `server`, `postgres` -- providing two different modes for running Dachs.

The first one we just saw running in the example above:

- `gavodachs/dachs[:tag]` provides a "one-shot" solution for having
Dachs running in its simple; Dachs-server and Postgres run inside
the same container.

The other two images provide `dachs` and `postgres` in their individual
containers, to run in parallel, the latter serving the former:

- `gavodachs/server[:tag]` provides gavodachs-server, it depends on another
  container providing postgres (on default port 5432).
- `gavodachs/postgres[:tag]` provides PostgreSQL for use by _dachs-server_.


**ToC**

* [Getting started](#getting-started)
  * [Test migration](#test-migration)
    * [DaCHS 2](#dachs-2)


Check the documents directory ([docs/](docs/)) for (practical) notes on

* [versioning your resources](docs/data_publication.md),
* [persisting data](docs/data_persistence.md),
* [upgrading DaCHS](docs/upgrade_dachs.md),
* [running dachs and postgresql individually](docs/individual_containers.md).

---

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

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/
[2]: https://docs.docker.com/


/.\
