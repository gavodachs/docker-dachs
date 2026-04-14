### LOCAL FOLDERS and file locations

# your configuration files for DaCHS configuration (including gavo.rc etc.)
# for build relativ to Dockerfiles
CONFIG_DIR=dachs/bin_composed

# Scripts to be copied to containers on build relative to Dockerfiles
DOCKER_BIN=dachs/bin_composed

### DaCHS Target Directories
GAVO_ROOT=/var/gavo
GAVO_INPUTS=${GAVO_ROOT}/inputs
GAVO_DATA=${GAVO_ROOT}/data

### DOCKER IMAGE SETTINGS

# Base image of debian
BASE_IMAGE="debian:stable" 

# BUILD argument for extra repositories (besides debian/stable) to install dachs.
# Options are:
# - "gavo/beta" (gavo/release + gavo/beta)
# - "backports" (debian/backports)
# - "main" (debian/main)
# * Default is "main"
INSTALL_REPO=main

# make sure to use the postgres version available in the package registry of the base image
# matches the version used here
PG_VERSION=17

# names of the postgres and dachs docker container and endpoint of the DaCHS server
PG_NAME=postgres
DACHS_NAME=dachs
SERVER_PORT=8080