# Dachs build

### TL;DR
At the simplest, building Dachs is done through:
```bash
$ docker build -t dachs .
```
This will create a container with the latest version of Dachs-stable.

> **DaCHS and Debian**
> 
> [DaCHS version 2.3 is now included in Debian Bullseye main/stable distribution.](https://packages.debian.org/bullseye/gavodachs2-server)
> 
> Accordingly, Dachs-on-Docker is now based on `debian:bullseye` image.


## Backports and Beta repositories
_Par défaut_, _dachs_ will be installed from debian-stable repository.
If you feel like -- or _need_ -- to install some upgrade or patch 
(not available in debian-stable) you can make use of backports/beta repositories,
which you specify during Dachs-on-Docker building time.

The (`build-arg`) option you have to set is `INSTALL_REPO`.

`INSTALL_REPO` understands the following values:
* `main`: _default_. You'll have the same DaCHS for ~2 years;
* `backports`: enables Debian `bullseye-backports`. You get major versions as upgrades;
* `beta`: enables GAVO _release_ and _beta_ repositories. You get to check the bleeding edge.

To build an image with _backports_ you will do:
```bash
$ docker build --build-arg INSTALL_REPO='backports' -t dachs:backports .
```

Likewise,, to build a beta-enabled image:
```bash
$ docker build --build-arg INSTALL_REPO='beta' -t dachs:beta .
```
