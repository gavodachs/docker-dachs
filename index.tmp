# DaCHS on Docker

This repository contains the dockefiles for encapsulating DaCHS.

[DaCHS](http://dachs-doc.readthedocs.io) is suite for managing
astronomical data publication through Virtual Observatory (VO)
standards (see [IVOA](http://www.ivoa.net)).

This repository is composed by three *meaninful* branchs:

* master
* dachs
* postgres

The DaCHS software provides data access services while keeping
two daemons running in background, a DBMS (PostgreSQL) server
and the Dachs server itself responsible for the data management
between user interface and database handling.

The branches are meant to split the services in different images,
available at [Docker Hub](https://hub.docker.com/r/chbrandt/dachs/).

While the `master` branch provides the "default" -- `latest` -- 
image, containing the all-in-one package: dachs + postgres,
the other branches, `dachs` and `postgres` provide the respective
servers on their own.
The `master` branch has _two_ dockerfiles actually: the one
inside `data/` is a dataset example, also individually built.

(Y)
Carlos
