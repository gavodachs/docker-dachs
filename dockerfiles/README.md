# Dachs-on-Docker recipes

Here you'll find docker container recipes and build scripts for Dachs and surrounding services.

The primary container is [`dachs`](dachs/), inside it's directory you'll find
more detailed information on it's building and content.
Although `dachs` is self-sufficient, you can have a [`postgres`](postgres/)
container servicing the database.
[Awstats](https://awstats.sourceforge.io/) was adopted to parse Dachs' logs,
the use of it is completely optional too.

Look in [`docker-compose`](docker-compose.yml) for an example of services setup.

## Run compose

To run (and build if not yet) all the containers:

```bash
$ docker-compose -f docker-compose.yml -d up
```
