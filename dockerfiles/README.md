# Dachs-on-Docker recipes

Here you'll find docker container recipes. In each directory, the files
necessary to build the respective images. The primary, fundamental container
in this scenario is [`dachs`](dachs/), inside it's directory you'll find
more detailed information on it's building and (image) content.

Next to `dachs` (container) you can arrange other container, naturally,
if you want to instantiate or split services among "composed" containers.

For instance, in [`awstats`](awstats/) you'll find the recipe for a container
providing [Awstats](https://awstats.sourceforge.io/) for access-log stats.
You should be able to spin up both containers using `docker-compose.awstats.yml`
provided:

```bash
$ docker-compose -f docker-compose.awstats.yml
```
