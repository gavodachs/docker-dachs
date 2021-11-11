# Dachs build

### TL;DR
At the simplest, building Dachs is done through:
```bash
$ docker build -t dachs .
```
This will create a container with the latest version of Dachs-stable.

> **DaCHS and Debian**
> 
> DaCHS version 2.3 is now included in Debian Bullseye main/stable distribution.
> * https://packages.debian.org/bullseye/gavodachs2-server
> 
> Dachs-on-Docker is in sync with that, and now using `debian:bullseye` base image.
> _Par défaut_, _dachs_ (stable) will be installed from debian/main repository, 
> though testing/patch installations can be achieved with [backports/beta repositories](#-Backports-and-Beta-repositories).


## Backports and Beta repositories
If you feel like -- or _need_ -- install some Dachs upgrade or patch, not available in
Debian/main repository, you can specify that during the container building.

The (`build-arg`) option you have to set is `INSTALL_REPO`.

`INSTALL_REPO` understands the following values:
* `main`: _default_
    - you'll have the same DaCHS for ~2 years
* `backports`: enables Debian `bullseye-backports`
    - you get major versions as upgrades;
* `beta`: enables GAVO _release_ and _beta_ repositories
    - you get to check the bleeding edge;

> Have a look at [./etc/apt_sources.list](./etc/apt_sources.list) if you want to check apt-sources.

To build an image with _backports_ you will do:
```bash
$ docker build -t dachs:backports \
               --build-arg INSTALL_REPO='backports'
               .
```

Likewise,, to build a beta-enabled image:
```bash
$ docker build -t dachs:beta \
               --build-arg INSTALL_REPO='beta'
               .
```
