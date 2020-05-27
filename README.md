# DaCHS on Docker

**ToC**
* [Getting started](#getting-started)
  * [Feeding data: ARIHIP](#feeding-data-arihip-example)
    * [A note on data persistence](#a-note-on-data-persistence)
* [Using Docker Compose](#using-docker-compose)
* [FROM `dachs:server`](#from-dachsserver)
* [~Best practices](#best-practices)
* [This repository structure](#this-repository-structure)
* [Debugging things](#debugging-things)

> If you have _suggestions or issues_ on running Dachs-on-Docker,
consider filling an [issue on Github](https://github.com/chbrandt/docker-dachs/issues).

---

This repository contains the dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).
You'll find the corresponding images in ['chbrandt/dachs' DockerHub repository][4].
DaCHS (or _suite_) is composed by a Postgres server in the background managed
by the _dachs-server_ which interfaces the database to the user.

The dockerfiles in here will setup image families (with their respective tags):
* `chbrandt/dachs`: DaCHS server + Postgres db -- used for testing only
* `chbrandt/dachs:server`: the DaCHS data-manager/server suite
* `chbrandt/dachs:postgres`: the Postgres db used by DaCHS

> In this document we'll see how to run [Dachs-on-Docker][4], the containerized
> version of DaCHS.
> For detailed information on DaCHS itself or Docker, please
> visit their official documentation, [DaCHS/docs][1] or [Docker/docs][5].
>
> Command-lines running from the _host_ system are prefixed by <code>(host)</code>.
> And command-lines preceded by <code>(dock)</code> are run from inside the container.

[1]: http://dachs-doc.readthedocs.io


# Getting started

* Docker image tags: `latest`,`stable`,`bundle` (and `1`,`1.4`,`all-in-one`)

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


### DaCHS-2 (beta)

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

# DaCHS and PostgreSQL containers

[Dachs-on-Docker][4] is a combination of two services/containers, a Postgres
(`chbrandt/dachs:postgres`) db/container and the Dachs server/container
(`chbrandt/dachs:server`):
```
(host)$ docker run -dt --name postgres chbrandt/dachs:postgres
(host)$ docker run -dt --name dachs --link postgres -p 80:80 chbrandt/dachs:server
```
After those lines, go to <http://localhost> (in the web browser) to see the
default DaCHS web interface.

_DaCHS-on-Docker_ is running.

> *Note:* the `postgres` container _must_ be named "`postgres`" when running it.

Cool.
Before going to the next session -- where we'll add some data to it--, let's first
handle for a moment the Docker command-line interface to change the state of DaCHS.

Let's modify our site's _title_.
We will do that by adding the respective parameter to dachs' configuration file, and
then restart `gavo` (the `dachs` daemon):
```
$ docker exec dachs bash -c 'echo "sitename: Short Site-name" >> $GAVOSETTINGS'
$ docker exec dachs bash -c 'gavo serve restart'
```

Going back to the browser's <http://localhost> (possibly refresh the page),
we should see the new title "Short Site-name".

That's quite cute, isn't it? Now let's put some data in it.


### Feeding data: ARIHIP example

We will now adapt the original [example from the DaCHS documentation][example]
to our container.
Steps are basically the same, we just have to change the perspective:

[example]: http://docs.g-vo.org/DaCHS/tutorial.html#building-a-catalog-service

1. Download the ARIHIP RD and data files:
  ```
  $ mkdir -p arihip/data
  $ curl http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd -o arihip/q.rd
  $ curl http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz -o arihip/data/data.txt.gz
  ```
2. Copy the ARIHIP files into the container:
  ```
  $ docker cp arihip dachs:/var/gavo/inputs/.
  ```
3. Import, publish, reload the service:
  ```
  $ docker exec -it dachs bash -c 'gavo imp arihip/q && gavo pub arihip/q'
  $ docker exec dachs bash -c 'gavo serve reload'
  ```

...and the ARIHIP dataset should be available at <http://localhost>.


#### A note on data persistence

Containers are volatile environments: whatever you do inside a container while
it is alive will go away when it is removed.

For instance, in our example, ARIHIP (and the previous modification to `sitename`)
will evaporate together with the container in case of a restart.
See it for yourself:

1. Remove the running containers
  ```
  $ docker rm -f dachs postgres
  ```
2. Start the containers as in the [previous subsection](#getting-started)
3. Check <http://localhost>, the default/empty DaCHS web site is back online.

There are different ways to persist data in Docker containers, it depends
very much on the surrounding infrastructure, demands through time and even
the kind of workflow from who manages the data/services.

In the [wiki] -- [Persisting data] -- we workout some models to persist
datasets throught shutdowns.

[wiki]: https://github.com/chbrandt/docker-dachs/wiki
[persisting data]: https://github.com/chbrandt/docker-dachs/wiki/Persisting-data

[5]: https://docs.docker.com/


## Using Docker Compose

Docker Compose is a clean way of running multiple containers that, like this setup,
work together to provide a seamless service.

Details about Docker Compose and how to install the `docker-compose` command
are found in the docs:
* Overview: <https://docs.docker.com/compose/overview/>
* Install: <https://docs.docker.com/compose/install/>

Long-story-short, once you have a `docker-compose.yml` file (below), you'll
have to type as much as,
```
$ docker-compose up
```
to have you containers running.

A `docker-compose.yml` to do exactly what we've done in the [first section][#getting-started]
will look like:
```
version: '3'
services:
    dachs:
        image: chbrandt/dachs:server
        container_name: dachs
        tty: true
        network_mode: 'bridge'
        ports:
            - '80:80'
        links:
            - postgres
        depends_on:
            - postgres
    postgres:
        image: chbrandt/dachs:postgres
        container_name: postgres
        tty: true
        network_mode: 'bridge'
```

## FROM `dachs:server`

Docker containers have an _inheritance_ mechanism in place that enables the
specialization of _base images_ to different applications.
_Dachs-on-Docker_ is meant to be inherited and further customized.

As far as I understand, you will likely want to customize `dachs:server` image,
where the interface with the user and data management takes place.

One aspect that you probably want to adjust is your site's metadata (_e.g._,
title, URL).
Which is about time now that we've gone through the very basics.

In the very first section, "Getting started", we changed the name of the our
site to "Short Site-name" through `docker exec`.
Now, we want to make that modification, for example, as part of a _custom_
container.

The guidelines are:
* To _build_ a container we need to define a `Dockerfile`;
* We will define our own DaCHS' `gavo.rc`;
  * And in the `Dockerfile`, substitute the default `gavo.rc`.

**We start** in an empty directory, by defining the following `Dockerfile`:
```
FROM chbrandt/dachs:server
COPY etc/gavo.rc /etc/gavo.rc
```

**Then**, we define the site's metadata (in `etc/gavo.rc`):
```
$ mkdir etc
$ cat > etc/gavo.rc << EOF
[web]
sitename: Short Site-name
bindAddress:
serverPort: 80
serverURL: http://localhost
EOF
```

* *Note:* the current directory has (currently) the files:
```
Dockerfile
etc/
`- gavo.rc
```

**Build** docker image:
```
$ docker build -t mydachs:server ./
```

There you go; Previously, we used `chbrandt/dachs:server`, now, `mydachs:server`
should do the work.


## ~Best practices
Now that we covered the first steps, we may go further on merging
containers with the structure of Dachs:
* <a href='./_Data_Persistence.md'>_Data persistence_</a>
* <a href='./_Workflow.md'>_Workflow_</a>


## Debugging things

If things don't work and you want to fix the docker files

```
(host)$ git clone https://github.com/chbrandt/docker-dachs
(host)$ cd docker-dachs
# The repo uses different branches to keep the dockerfiles for
# dachs and postgres, respectively:
(host)$ git checkout postgres
# use --no-cache to verify things actually build properly from scratch
(host)$ docker build -t dachs_postgres dockerfile/
# do the same for the dachs container
(host)$ git checkout dachs
(host)$ docker build -t dachs_dachs dockerfile/
```

Now open two shells; while you'll normally want to run things in detached mode
and just jump in with `docker exec -it dachs bash` (or so), for debugging
it's usually a good idea to see what's going on:

```
(host)$ docker run --rm -it --name postgres dachs_postgres
(host)$ docker run --rm -it --name dachs --link postgres -p 80:80 dachs_dachs
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

This ([Github][3]) repository offers a `docker-compose.yml` file.


/.\
