# Dachs build

> **DaCHS and Debian**
>
> [DaCHS version 2.3 is now included in Debian Bullseye main/stable distribution.](https://packages.debian.org/bullseye/gavodachs2-server)
>
> Accordingly, Dachs-on-Docker is now based on `debian:bullseye` image.


### TL;DR
At the simplest, building Dachs is done through:

```bash
$ docker build -t dachs .
$ docker run -it --name some-dachs -p 8080:8080 dachs
```

This will create a container with the `latest` version of Dachs (using GAVO's repository),
and then run it (exposing port 8080 to localhost).

> This (default) container runs both _dachs-server_ and _postgres_.


## Debian/GAVO repositories
_Par défaut_, _dachs_ will be installed from debian-stable (main) repository.
If you feel like -- or _need_ -- to install some upgrade or patch
you can make use of Debian backports or GAVO's release/beta repositories.
You specify those on the building of the containers.

The (`build-arg`) option you have to set is `INSTALL_REPO` for that.
`INSTALL_REPO` understands the following values:
* `gavo`: _default_. Enables GAVO _release_ and _beta_ repositories. You get to check the bleeding edge.
* `backports`: enables Debian `bullseye-backports`. You get major versions as upgrades;
* `main`: . You'll have the same DaCHS for ~2 years;

> Defining `gavo`, `latest` or _non_ declaring `INSTALL_REPO` have the same effect:
> to build the _latest_ images (i.e, _gavo_)

The latest/gavo image:
```bash
$ docker build --build-arg INSTALL_REPO='gavo' -t dachs:gavo .
$ docker tag dachs:gavo dachs:latest
```

To build an image with _backports_ you will do:
```bash
$ docker build --build-arg INSTALL_REPO='backports' -t dachs:backports .
```

Likewise, to build an image with only what's in Debian `main` repo:
```bash
$ docker build --build-arg INSTALL_REPO='main' -t dachs:main .
```
