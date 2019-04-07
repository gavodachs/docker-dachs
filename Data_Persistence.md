# Data Persistence

Remember that containers have a volatile state: when they are removed, data
modified _inside_ the container's (virtual) filesystem will be deleted.
Clearly, we need to workout a setup where data and settings
remain safe -- _persist_ -- across container shutdowns/upgrades.

Docker _volumes_ is a central concept to this argument as volumes are essentially
mounting points between the host and the container or among containers.
Through _volumes_ we can
* either keep the data in the host and share them with the container,
* or dedicate a container for the storage and serve it to other container(s).
Again, the best strategy depends very much each data provider's workflow and
amount of data.

Notice that we are not particularly talking about your Dachs' site settings,
although clearly the arguments of data persistence apply also to those files.
I understand that site settings are likely to be persistet through a customized
_dachs-server_ image, but this is just a personal taking, not necessarily your case.

Generally, when we think about data to persist across Dachs instances, we think
on the contents of:
* `/var/gavo/inputs/*`: _par default_ the services directories;
* `/var/gavo`: _almost completely_ defines the site;
* `/etc/gavo.rc`: site's metadata.

And persisting the data of all those directories, and how is up to you, I'll
here present a couple of examples to illustrate the mechanism.
Take the chance to read also the companing document ["Workflow"] for it has
quite a synergy with the content in here.


## Volumes from host to container

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
(host)$ docker run -dt --name dachs -p 80:80                        \
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
$ # Docker-run the 'postgres' container previously, and then...
(host)$ docker run -dt --name dachs -p 80:80                         \
                   -v /dachs/sets/arihip:/var/gavo/inputs/arihip     \
                   -v /dachs/sets/datasetx:/var/gavo/inputs/datasetx \
                   -v /dachs/utils:/usr/host/utils                   \
                   -v /dachs/etc/gavo.rc:/etc/gavo.rc                \
                   chbrandt/dachs:server
```

## Volumes among containers
