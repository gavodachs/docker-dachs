# Workflow

* [Service versioning]
* [Dachs upgrade]


## Service versioning

When maintaining a service it is reasonable to keep the config files in
a versioning system (SCM).
And if the data being published is not much, there is no reason to not keep
it _too_ under versioning.

How much of data is _reasonable_ to versionize, if GitHub is an upstream, I'd
say data files no larger than `50 MB`.
But if a dedicated server is being use as pool, then this threshold can rise
as necessary.

[Git](https://git-scm.org) is a very popular SCM, it is the one being used now,
for example.

We start from a directory dedicated to a DaCHS service, clean from other
files but `data.csv` and `q.rd`.
`data.csv` is an uparticular "data" file, not of much interest right now,
but reasonably small so that we can _commit_ it to github.

If there is no `q.rd` yet, we create a minimal one:
```
$ cat q.rd
<resource schema="datasetx">
  <meta title="Dataset-X"
  <meta description="This is a dataset of X-events. Ever up-to-date."
</resource>
EOF
```

We can start versioning:
```
$ git add q.rd data.csv
$ git commit -am "Init. Minimal RD and data sample"
```

---
*Note*: if using an upstream (_e.g._, Github), keep it updated with `git push`
after `git commit`.
---

As the RD evolves, versioning takes place as frequent as possible/reasonable.
For example, let's say we defined all `<meta>` fields we feel important to
inside `<resource>`.
Would be reasonable to _tag_ the repository with a "v0.1" or "alpha" version,
```
$ git tag -a m "<meta> data defined for <resource>" 0.1_dev
```
(And `git push --tags`, if upstream.)

The development of the service (RD) and setup of data may evolve in a workstation
with the docker container until it gets into a stable version ("v1").
At this point, the data publisher should simply synchronize (`git clone`),
from the upstream (Github), and _publish_ the service. _E.g._,
```
$ cd /var/gavo/inputs
$ git clone <url>
```

In this workflow we avoid directly copying files, a separated _repository_
simplifies the bi-directional synchronization of the files, and we win
quite a reliable backup in the meantime :)


## Mounting working directory to containers

I like to see the development process of a (Dachs) service as composed by one of
more cycles of "_feature implementation_ > _test_ > _fix eventual error_ > _test_".
Actually, to support this cycle was the primary motivation for _DaCHS-on-Docker_:
to have an efficient "sandbox" so that I could simply dump my
environment and start from fresh.

During this process, it is reasonable to have the current _service_ directory
shared between _host_ and the _dachs_ container, it allows one to edit RD/data
files using editor/tools from the host system while -- whenever necessary to _test_ --
`gavo imp/pub/...` is promptly available through the container.

To do so, we'll use docker's option `--volume|-v`.

Let's say our previous service example ("Dataset-X") is under '`/data/datasetx/`',
we can run our container like,
```
# Docker-run the 'postgres' container previously, and then...
#
(host)$ docker run -dt --rm --name dachs_datasetx -p 80:80 \
                   -v /data/datasetx:/var/gavo/inputs/datasetx \
                   chbrandt/dachs:server
```

And whenever the service is good to try,
```
(host)$ docker exec -it dachs_datasetx bash
(cont)$ gavo imp datasetx/q
(cont)$ gavo pub datasetx/q
```

At any given moment, `dachs_datasetx` container can be stoped and even removed.
Files under `/data/datasetx/` will staty there. as any other file in the filesystem.
