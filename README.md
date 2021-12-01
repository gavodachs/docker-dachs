# DaCHS on Docker

[![Build Status](https://travis-ci.com/gavodachs/docker-dachs.svg?branch=master)](https://travis-ci.com/gavodachs/docker-dachs)

> ###### NOTE:
> Recently, the Dachs-on-Docker images repository -- on DockerHub -- have been
> changed from `chbrandt` to `gavodachs`organisation.
> The documentation is being reviewed and updated accordingly, but if/whenever
> you see a `chbrandt/dachs`, read, change it to `gavodachs/dachs`.

Here you'll find recipes for building and running [GAVO DaCHS](http://docs.g-vo.org/DaCHS/)
in Docker containers.

These files build the images available in DockerHub's [_gavodachs_][gavodachs] repositories.

[gavodachs]: https://hub.docker.com/u/gavodachs


## Quick Dachs
DaCHS _service_ is composed by two daemons: PostgreSQL and the Dachs _server_.
Postgres stores the data, while Dachs-server interfaces the user (web, api) and
manages the astro/planetary data accordingly.
By default, Dachs provides its (api) endpoints at port `8080` on `localhost`.

> For fine details about DaCHS, refer to the official docs: [soft.g-vo.org](https://soft.g-vo.org/dachs).

### Run it
If all you wanna do now is to see _Dachs-on-Docker_ running:

```bash
[~/]$ docker run -it -p 8080:8080 --name dachs gavodachs/dachs

# some initialization output (...)

[root@10dd4547e]$ service postgresql start
Starting PostgreSQL 13 database server: main.
[root@10dd4547e]$
[root@10dd4547e]$ dachs serve debug
<date> [-] Log opened.
<date> [-] Site starting on 8080
<date> [-] Starting factory <twisted.web.server.Site object at 0x7fb33c844fd0>
Starting VO server: dachs.

```
Docker `run` will instantiate the container and hand you a bash session from inside the container.
Then we start Postgres to finally start Dachs (in `debug` mode to have it verbose).

> The `/dachs.sh` you will find in the container is a simple script to start/stop
> the servers for your convenience (eg, `/dachs.sh start` will do the above steps).


You go to [http://localhost:8080](http://localhost:8080) and you should see Dachs frontpage:
![Landing page](docs/landing_page.png)

And in the terminal, lines like the following should pop out in the terminal:

```bash
<date> [-] 172.17.0.1 - - [<date>] "GET / HTTP/1.1" 200 1221 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15"
<date> [-] 172.17.0.1 - - [<date>] "GET /static/js/jquery-gavo.js HTTP/1.1" 200 66576 "http://localhost:8080/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15"
<date> [-] 172.17.0.1 - - [<date>] "GET /static/img/logo_medium.png HTTP/1.1" 200 48422 "http://localhost:8080/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15"
(...)
```

While this terminal is being used by `dachs` server we can open another terminal
and attach to the same container (dachs):

```bash
[~/]$ docker exec -it dachs bash
[root@10dd4547e]$
[root@10dd4547e]$ # The services running, for example:
[root@10dd4547e]$
[root@10dd4547e]$ ps ax
  PID TTY      STAT   TIME COMMAND
    1 pts/0    Ss     0:00 /bin/bash --rcfile /help.sh
   50 ?        Ss     0:00 /usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/13/main -c config_file=/etc/postgresql/13/main/postgresql.conf
   52 ?        Ss     0:00 postgres: 13/main: checkpointer 
   53 ?        Ss     0:00 postgres: 13/main: background writer 
   54 ?        Ss     0:00 postgres: 13/main: walwriter 
   55 ?        Ss     0:00 postgres: 13/main: autovacuum launcher 
   56 ?        Ss     0:00 postgres: 13/main: stats collector 
   57 ?        Ss     0:00 postgres: 13/main: logical replication launcher 
   75 pts/0    Sl+    0:01 /usr/bin/python3 /usr/bin/dachs serve debug
   76 ?        Ss     0:00 postgres: 13/main: gavo gavo 127.0.0.1(53334) idle
   78 ?        Ss     0:00 postgres: 13/main: gavo gavo 127.0.0.1(53338) idle
  133 pts/1    Ss     0:00 bash
  139 pts/1    R+     0:00 ps ax
  [root@10dd4547e]$
```


### Docker Images
The containers are built on top of Debian Bullseye image, which GAVO/DaCHS is part
of the _main_ (and _backports_) repository (current Dachs version: 2.3).
For the `latest` images we use also GAVO repositories, where updates go first (current Dachs version: 2.5).

> For more details on _building_ images, go to [dockerfiles/README.md](dockerfiles/README.md)

There are three images in our context: `dachs`, `server`, `postgres`.
Those three images are to provide two different running setup:
using just one image, `dachs`, like we just did; 
Or as a pair of containers, `postgres` and (dachs) `server`, talking to each other.

The single-container setup:

- `gavodachs/dachs[:tag]` provides a "one-shot" solution for having
Dachs running in its simple; Dachs-server and Postgres run inside
the same container.

The other two images provide Dachs and Postgres in their individual containers:

- `gavodachs/server[:tag]` provides gavodachs-server, depends on `postgres`.
- `gavodachs/postgres[:tag]` provides PostgreSQL for use by _dachs-server_.

  > How to run `server`/`postgres` is covered in page 
    ['individual_containers.md'](docs/individual_containers.md).

#### Tags
The tags reflect the _apt_ repositories set up in there:

- `latest`,`gavo`: uses all repositories (Debian and Gavo)
- `backports`: uses all _Debian_ repositories
- `main`: uses only Debian's `stable/main`

- - -



**ToC**
> See [`etc/apt_sources.list`](dockerfiles/dachs/etc/apt_sources.list) for the 
> actual list of repositories used (they are enabled-or-not during the building of
> the image, according to _building arguments_).


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
