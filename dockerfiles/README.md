# Dachs-on-Docker recipes

Here you'll find docker container recipes and build scripts for Dachs and surrounding services.

Here will compose the following containers:

**DaCHS**

- dachs (_sandbox_ container running dachs-server and postgres)
- dachs-server (container running only dachs-server)
- dachs-postgres (container running only postgres)

**Extra**

- awstats (optional, container providing Awstats)

In default _compose_ file (`docker-compose.yml`) there is `dachs` (and `awstats`).
In _compose_ `docker-compose.full.yml`, you'll see `dachs-server` and `dachs-postgres`
(and `awstats`) composing individual services.


## Build details
Have a look in the [README file in `dachs/`](dachs/README.md) for details on
building the individual containers.


## Run compose
> If you don't have yet, install [`docker-compose`](https://docs.docker.com/compose/install/).

To run (and build if not yet) the containers:

```bash
$ docker-compose up
```

This will use `docker-compose.yml` to build and run containers.
The default Dachs container built is the _latest_ `dachs` container
-- using GAVO's apt repository.

To run dachs/postgres server containers individually, `docker-compose.full.yml`
is a sample of such setup:

```bash
$ docker-compose -f docker-compose.full.yml
```


## Build compose

To (re)build the containers defined in a compose file:

```bash
$ docker-compose build
```


## Environment variables
The variables used in the _compose_ files can be defined in an "env" file
to fix some settings on the containers building and running.

See [`env.rc`](env.rc) for an example:
```
# Local path for Dachs logs (persistence)
DACHS_LOGS_PATH="./logs/dachs"

# Local path data/files to mount
DACHS_DATA_PATH="./data"

# Dachs branch/repository version.
# Options are: main, backports, gavo (=latest).
INSTALL_REPO=latest
```

Example run:
```bash
$ docker-compose --env-file env.rc up
```
