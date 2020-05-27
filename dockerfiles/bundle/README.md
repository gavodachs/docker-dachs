# Bundle build

On building _docker-dachs_ some arguments can be used to customise some settings.
Through the use of option `--build-arg` on `docker build` the user can define
environment variable to be used inside the Dockerfile.

For the _bundle_ image, the following arguments/variables can be used:
* `APT_REPO`: options are 'release' (default) and 'beta'
* `PKG_NAME`: options are 'gavodachs-server' (default) and 'gavodachs2-server'

For instance, to build the latest _release_ version of dachs (v1.x):
```bash
$ docker build -t mydachs .
```

To build the _beta_ version of dachs-2:
```bash
$ docker build -t dachs2 \
               --build-arg APT_REPO='beta' \
               --build-arg PKG_NAME='gavodachs2-server' \
               .
```

## Commands used to build and tag _bundle_ images:
```
# Dachs release
docker build --no-cache -t chbrandt/dachs:release .

docker tag chbrandt/dachs:release chrandt/dachs:latest
docker tag chbrandt/dachs:release chrandt/dachs:stable
docker tag chbrandt/dachs:release chrandt/dachs:bundle
docker tag chbrandt/dachs:release chrandt/dachs:1
docker tag chbrandt/dachs:release chrandt/dachs:1.4
docker tag chbrandt/dachs:release chrandt/dachs:all-in-one

# Dachs 2/beta
docker build --no-cache \
             -t chbrandt/dachs:beta \
             --build-arg APT_REPO=beta \
             --build-arg PKG_NAME=gavodachs2-server \
             .

docker tag chbrandt/dachs:beta chrandt/dachs:2-beta
docker tag chbrandt/dachs:beta chrandt/dachs:2
```
