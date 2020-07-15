# Bundle build

On building _docker-dachs_ some arguments can be used to customise some settings.
Through the use of option `--build-arg` on `docker build` the user can define
environment variable to be used inside the Dockerfile.

For the _bundle_ image, the following arguments/variables can be used:
* `APT_REPO`: options are 'release' (default) and 'beta'
  * 'release' is actually *always* used, 'beta' (in case) would be suplementary;
* `PKG_NAME`: options are 'gavodachs2-server' (default) and 'gavodachs-server'

For instance, to build the latest (_release_) version of dachs (v2.x):
```bash
$ docker build -t mydachs .
```

To build a _beta_ version of dachs (v2):
```bash
$ docker build -t mydachs_beta \
               --build-arg APT_REPO='beta' \
               --build-arg PKG_NAME='gavodachs2-server' \
               .
```

## Commands used to build and tag _dachs (bundle)_ images:
```
# Dachs v2
docker build --no-cache -t chbrandt/dachs:2 .

docker tag chbrandt/dachs:2 chbrandt/dachs:2.1
docker tag chbrandt/dachs:2 chbrandt/dachs:latest

# Dachs v1
docker build --no-cache \
             -t chbrandt/dachs:1 \
             --build-arg PKG_NAME=gavodachs-server \
             .

docker tag chbrandt/dachs:1 chbrandt/dachs:1.4
```
