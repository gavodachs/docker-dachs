# Data Persistence

Remember that containers have a volatile state: when they are removed, data
modified _inside_ the container's (virtual) filesystem will be deleted.
Clearly, we need to workout a setup where data and settings
remain safe -- _persist_ -- across container shutdowns/upgrades.

Docker _volumes_ is a central concept to this argument, volumes are essentially
mounting points between the host and the container or among containers.
Through _volumes_ we can
* either keep the data in the host and share them with the container,
* or dedicate a container for the storage and serve it to other container(s).
The best strategy depends very much on each data provider's workflow and the
amount of data.
Anyways, we will here (together with the <a href='./_Workflow.md'>_Workflow_</a>
document) handle a couple of examples on the subject.

Generally, when we think about data to persist across Dachs instances, we think
on the contents of:
* `/var/gavo/inputs/*`: _par default_ the services directories;
* `/var/gavo`: _almost completely_ defines the site;
* `/etc/gavo.rc`: site's metadata.

Site's metadata, though, is something rather stable -- actually, _static_ -- in
every site.
For that component, it may be reasonable to have it in a custom container after
inheriting from `chbrandt/dachs:server` like shown in the [README, 'FROM dachs:server' section](README#from-dachsserver).


## Host-Container volumes

Let's consider we have a set of services under our host's `/dachs/sets`:
```
$ tree /dachs/sets
/dachs/sets/
├── arihip
│   ├── data
│   │   └── data.txt.gz
│   └── q.rd
└── datasetx
    ├── data.csv
    └── q.rd
```

We can run our Dachs container/site as follows:
```
$ # Docker-run the 'postgres' container previously, and then...
(host)$ docker run -dt --name dachs -p 80:80                         \
                   -v /dachs/sets/arihip:/var/gavo/inputs/arihip     \
                   -v /dachs/sets/datasetx:/var/gavo/inputs/datasetx \
                   chbrandt/dachs:server
```

And then manage publication from another shell:
```
(host)$ docker exec -it dachs bash
(cont)$ gavo imp arihip/q && gavo pub arihip/q
(cont)$ gavo imp datasetx/q && gavo pub datasetx/q
(cont)$ gavo serve reload
```

Obviously, you can handle this process as best it fits your workflow.
For example, let's consider we have a "`utils`" directory next to our datasets
providing some utility scripts for managing our data.
Let's consider also that our site's metadata is kept in our (host) data storage
and pushed to every time we instantiate a _dachs-server_ container:
```
# Docker-run the 'postgres' container previously, and then...
(host)$ docker run -dt --name dachs -p 80:80                         \
                   -v /dachs/sets/arihip:/var/gavo/inputs/arihip     \
                   -v /dachs/sets/datasetx:/var/gavo/inputs/datasetx \
                   -v /dachs/utils:/usr/host/utils                   \
                   -v /dachs/etc/gavo.rc:/etc/gavo.rc                \
                   chbrandt/dachs:server
```


## Volume Containers

Another way to persist data in a docker setup is through _volume containers_.
Basically, _volume containers_ are containers dedicated to serve as a storage hub,
exporting volumes to other, running containers.

There are two ways to have a _volume container_:
1. (traditional) _build_ a container and expose specific `VOLUME` path;
2. (recommended) _create_ a `docker-volume` to store different paths.


### Traditional

This is the traditional way of creating a volume container, a `Dockerfile` is
defined to _export_ certain volumes.
For example, the following `Dockerfile` could be used to pool everything from
`/var/gavo`:
```
FROM debian
RUN mkdir -p /var/gavo
VOLUME /var/gavo
```

And if we built it with the following command line:
```
$ docker build -t mydachs:volume ./
```

We would then use it as:
```
(host)$ docker run -dt --name dachs_vargavo mydachs:volume
(host)$
(host)$ docker run -dt --name dachs -p 80:80      \
                   --volumes-from mydachs_volume  \
                   chbrandt/dachs:server
```

Everything you do inside `/var/gavo` (create, move, delete) will be saved in
`dachs_vargavo`.
Since you can _commit_ changes done to a container in a new image, you could
also _versionize_ your `dachs_vargavo` container (image, `mydachs:volume`) each
time a new service/resource comes in, for example.
Again, it is up to the data publisher to decide if it is a reasonable workflow;
You'll probably not do it if your services have a lot of data under them.


### Recommended

Nowadays docker provides the `volume` interface, specific for non-running
containers, dedicated to data persistence.
First thing to know about _docker volumes_ is that they are only deleted from
your host's filesystem when _explicitly_ removed -- which is a nice, very safe
feature (though, notice, if you decide to play with volumes and forget to
clean after it, data may start to accumulate under the hood.)

To create a docker volume is rather simple:
```
$ docker volume create dachs_store
```

And then, we can "mount" whichever path we want during the companion container's
initialization:
```
$ docker run -dt --name dachs -p 80:80   \
             -v dachs_store:/var/gavo    \
             -v dachs_store:/etc/gavo.rc \
             chbrandt/dachs:server
```

If the volume-container is empty at a path (_e.g._, `/var/gavo`), it will copy
the content from the companion container (_e.g._, `dachs`); otherwise, will
just mount it at the corresponding location exposing its content.
