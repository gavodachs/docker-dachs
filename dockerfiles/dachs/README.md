# Dachs build

At the simplest, building Dachs is done through:

```bash
$ docker build -t dachs .
$ docker run -it --name some-dachs -p 8080:8080 dachs
```

This will create a container with the latest stable version of Dachs,
as available in Debian 'main' repository.


## Debian/GAVO repositories
_Par défaut_, _dachs_ will be installed from debian-stable (main) repository.
If you feel like -- or _need_ -- to install some upgrade or patch
you can make use of Debian backports or GAVO's release/beta repositories.

The (`build-arg`) option you have to set is `INSTALL_REPO` for that.
`INSTALL_REPO` understands the following values:
* `main`: This is the _default_. Stable, uses only Debian `main` repository;
* `backports`: Enables Debian `backports`, you'll get major versions as upgrades;
* `gavo/beta` (or `gavo`): Enables GAVO _release_ and _beta_ repositories. Minor or custom patches -- directly from the oven -- are here.

The latest gavo software:
```bash
$ docker build --build-arg INSTALL_REPO='gavo' -t dachs:gavo .
$ docker tag dachs:gavo dachs:latest
```

To build an image with _backports_ you will do:
```bash
$ docker build --build-arg INSTALL_REPO='backports' -t dachs:backports .
```

To build an image with only what's in Debian `main` repo:
```bash
$ docker build --build-arg INSTALL_REPO='main' -t dachs:main .
```
or, equivalently:
```bash
$ docker build -t dachs:main .
```
