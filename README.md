# DaCHS on Docker

Summary

* [Getting started](#getting-started)
  * [Feeding data: ARIHIP example](#feeding-data--arihip-example)
    * [A note on data persistence](#a-note-on-data-persistence)
* [This repository structure](#this-repository-structure)
* [How to use it](#how-to-use-it)
 * [Compose data volumes](#compose-data-volumes)
 * [Complete workflow example](#complete-workflow-example)
* [Further ways of running Dachs](#further-ways-of-running-dachs)

This repository contains the dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).
You'll find the corresponding images in [chbrandt/dachs Docker repository][4].

If you're here by chance and don't really know what [DaCHS][1] is, it is a software
system for astronomical data publication through the Virtual Observatory (VO)
standards and protocols (see [IVOA][2]).
The system (or _suite_) is composed by a Postgres server in the background managed
by the Dachs server, which interfaces the database to the user.

[1]: http://dachs-doc.readthedocs.io
[2]: http://www.ivoa.net


## Getting started

```diff
+ Command-lines that should run from you host system (MacOS, Linux) are prefixed
+ by <code>(host)</code>. And command-lines preceded by <code>(cont)</code> are
+ meant to be run from inside the container.
```

In what follows, we will focus on running [Dachs-on-Docker][4], the containerized
version of DaCHS; For detailed information on DaCHS itself or Docker, please
visit their official documentation, [DaCHS/docs][1] or [Docker/docs][5].

The easiest way to have [Dachs-on-Docker][4] running is by simply running the
Postgres (`chbrandt/dachs:postgres`) container and then the Dachs-server container
(`chbrandt/dachs:server`):
```
(host)$ docker run -dt --name postgres chbrandt/dachs:postgres
(host)$ docker run -dt --name dachs --link postgres -p 80:80 chbrandt/dachs:server
```

After doing it, we go to <http://localhost> (in our web browser) to see the
default DaCHS web interface; _DaCHS-on-Docker_ is running.

Now...before going to the next session, let's do a small trick...just because
we like tricks ;)
Let's modify the _name of our site_.
The next commands will modify the content of a Dachs's configuration file, and
then we will restart `gavo` (the `dachs` daemon):
```
$ docker exec dachs bash -c 'echo "sitename: Short Site-name" >> $GAVOSETTINGS'
$ docker exec dachs bash -c 'gavo serve restart'
```

And now, going back to our browser's <http://localhost> and refresh the page;
the new title "Short Site-name" (or whatever you decided to use) should be there.

That's quite, now let's put some data in it.


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
3. Import, publish, restart the service:
  ```
  $ docker exec -it dachs bash -c 'gavo imp arihip/q && gavo pub arihip/q'
  $ docker exec dachs bash -c 'gavo serve restart'
  ```

...and the ARIHIP dataset should be available to you at <http://localhost>.


#### A note on data persistence

Containers are temporary environments, whatever you do inside a container while
it is alive will go away with the container when it goes removed.

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

## Next steps: advancing the use of Dachs on Docker

Now that we've done the very first steps, we may start merging the flexibility
of containers within the structure of Dachs and, as indicated previously, we
can talk about data persistence, publishing workflow and composing services.


## This repository structure

This [Github][3] repository has four branches, `master`, `dachs`, `postgres`
and `all-in-one`. Except from `master` each repository is associated with
a different Docker image(/tag) -- `chbrandt/dachs`(`:tag`), available at [Docker Hub][4]:

| git branch | docker tag |
| --- | --- |
| `dachs` | `server` |
| `postgres` | `postgres` |
| `all-in-one` | `latest` |

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/

This ([Github][3]) repository offers a `docker-compose.yml` file.


## How to use it

### Compose data volumes

The *compose* file creates two data volumes, one for each container.

The data volume associated with the *dachs-server* mounts at `/var/gavo`;
the volume associated with *postgres server* mounts at where `data_directory`
is (for instance, at `/var/lib/postgresql/9.4/main`).

[5]: https://github.com/chbrandt/docker-dachs/blob/master/docker-compose.yml

The volumes are used to expose and persist the data.
Using data volumes will keep the data even when the parent containers go
down, restarted, upgraded.
You can manage the data inside the volumes through another --generic--
container, by mounting from the containers directly using `volumes-from` option.

For example,
```
$ docker run -it --rm --volumes-from dachs debian
```
will mount the volume from running `dachs` container, `/var/gavo`, inside
the new container.
The new container --which is running from a `debian` image-- will have
the content of `/var/gavo` at its disposal.
You can now do the modifications/additions you want and exit.
This container will be killed after its use (`--rm`).

### Complete workflow example

Let us now start a Dachs service from scratch and publish the famous
ARIHIP dataset.

1. Run docker-compose
```
[host] $ docker-compose -f docker-compose.yml up
```

2. Verify if dachs is running using your browser `http://localhost`.
If *yes*, proceed, otherwise email me (the service should start after
~30 seconds maximum).

3. Run a companion image to manage data inside `dachs`
```
[host] $ docker run -it --rm --name temp  \
          --volumes-from dachs            \
          debian:jessie
```

4. From *inside* the `temp` container, download and save the data:
```
[at-temp] $ apt-get update
[at-temp] $ apt-get install curl
[at-temp] $ mkdir /var/gavo/inputs
[at-temp] $ mkdir arihip && cd arihip
[at-temp] $ curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd
[at-temp] $ mkdir data && cd data
[at-temp] $ curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz
```
We can now exit from the `temp` container.

5. Finally, we just need to run the `import`/`publish` commands for `dachs`:
```
[from-host] $ docker exec -t dachs gavo import /var/gavo/inputs/arihip/q.rd
[from-host] $ docker exec -t dachs gavo publish /var/gavo/inputs/arihip/q.rd
[from-host] $ docker exec -t dachs gavo serve restart
```

You should have the ARIHIP dataset available at `http://localhost`.

To test data persistence, you can shutdown the `dachs`/`postgres` service
and then restart them to see the very same content at `http://localhost`.
```
$ docker-compose down
$ docker-compose up
```


## Further ways of running Dachs

Dachs on Docker comes in two flavors:
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

_Any doubt, comment or error, please file an [issue on Github](https://github.com/chbrandt/docker-dachs/issues)_

(Y)
Carlos
