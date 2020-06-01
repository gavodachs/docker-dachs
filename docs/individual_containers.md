# Individual containers

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
