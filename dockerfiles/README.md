# Dachs-on-Docker recipes

Here you'll find docker container recipes and build scripts for [DaCHS][_dachs]  
(and surrounding services).

[_dachs]: https://docs.g-vo.org/DaCHS/

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

Have a look in the [README file in `dachs/`](dachs/README.md) for details on
building the individual containers.

## Building dachs in single image

### Run compose
> If you don't have yet, install [`docker-compose`](https://docs.docker.com/compose/install/).

To run (and build if not yet) the containers:

```bash
$ docker-compose up
```

This will use `docker-compose.yml` to build and run containers.
The default Dachs container built is the _latest_ `dachs` container
-- using GAVO's apt repository.

To run dachs/postgres server containers individually, see description below.


### Build compose

To (re)build the containers defined in a compose file:

```bash
$ docker-compose build
```

### Environment variables
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

## Composed setup with separate server and database

### Container Specifications

The VO server is split into two functional components:

1.  Database Container (Dockerfile.dachs_postgres)
2.  Application Container (Dockerfile.dachs_server): Mounts `gavo.rc` to `/etc/gavo.rc` and expects the database to be reachable on startup

Use the docker-compose.full.yml (renamed to docker-compose.yml), variable setting in setenv.sh and make commands in the root directory to build the images. 

As the images use the Debian package system for installation, make sure that the according postgres version is available through apt.

### Building the containers

To build the containers, 

#### 1. Set the relevant environment variables in `setenv.sh` and run

```bash
source setenv.sh
```

In this file, the container names, endpoint for the dachs server and paths to supplementary files are defined. The files at `/bin_composed` are obligatory for running the containers, additional settings can be added by specifying a $CONFIGS folder holding e.g. files like the defaultmeta.txt.

#### 2. Building the containers

The included `Makefile` provides a standardized interface for building and running the stack.

* **Build the images**:
    ```bash
    make build
    ```
    *This executes `docker compose build` using the variables defined in your environment.*

* **Start the services**:
    ```bash
    make up
    ```
    *Starts the PostgreSQL and DaCHS containers in the background.*

* **Stop the services**:
    ```bash
    make down
    ```

