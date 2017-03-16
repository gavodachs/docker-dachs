# DaCHS on Docker

Summary

* [How to use it](#how-to-use-it)
 * [Compose data volumes](#compose-data-volumes)
 * [Complete workflow example](#complete-workflow-example)
* [Further ways of running Dachs](#further-ways-of-running-dachs)

This repository contains the image/dockerfiles for [GAVO DaCHS](http://docs.g-vo.org/DaCHS/).

[DaCHS][1] is a suite for managing astronomical data publication through Virtual Observatory (VO)
standards (see [IVOA][2]).

[1]: http://dachs-doc.readthedocs.io
[2]: http://www.ivoa.net

The DaCHS software provides data access services after two daemons running in background,
a DBMS (PostgreSQL) server and the Dachs server itself responsible for the data management
and user interface.

The [Github][3] repository has four branches, `master`, `dachs`, `postgres`
and `all-in-one`. Except from `master` each repository is associated with
a different Docker image, all automatically built at [Docker Hub][4].

[3]: https://github.com/chbrandt/docker-dachs
[4]: https://hub.docker.com/r/chbrandt/dachs/

This ([Github][3]) repository offers a `docker-compose.yml` file, which is
the recommended way of running DaCHS.


## How to use it

The recommended way of running DaCHS on Docker is through `docker-compose`.
`docker-compose.yml` will call `chbrandt/dachs:server` and
`chbrandt/dachs:postgres` to compose the service accessible through
`http://localhost` (port 80). The containers are name `dachs` and `postgres`,
respectively, and each one of them has a data volume associated
(see [Compose data volumes][compose-data-volumes]).

The [docker-compose file][5] is available at the master branch.
Suppose you have the [docker-compose.yml][5] in your current directory,
just type the following command to have the service running:
```
$ docker-compose up
```
...wait a few seconds and the web interface should show up at `http://localhost`.

*If you want to see further details about running DaCHS on Docker without
the compose, take a look at [Further ways of running Dachs](further-ways-of-running-dachs).*

After the service has been started, you can run commands to control
Dachs through docker's `exec` command.
For example, to order a `restart` of `dachs` server, we should do:
```
$ docker exec -it dachs gavo serve restart
```
This command line means:
* `gavo serve restart`: the command we want to run inside the container
* `dachs`: the name of the container we want to run the command
* `docker exec -t`: ask docker to execute the command in a terminal (`-t`)


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
[at-temp] $ mkdir arihip
[at-temp] $ cd arihip
[at-temp] $ curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd
[at-temp] $ mkdir data
[at-temp] $ cd data
[at-temp] $ curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz
```
We can now exit from the `temp` container.

5. Finally, we just need to run the `import`/`publish` commands for `dachs`:
```
[from-host] $ docker exec -t dachs gavo import arihip/q
[from-host] $ docker exec -t dachs gavo publish arihip/q
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



_Any doubt, comment or error, please file an [issue on Github](https://github.com/chbrandt/docker-dachs/issues)_

(Y)
Carlos
