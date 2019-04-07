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

In this workflow we avoid directly copy files, a separated _repository_
simplifies the bi-directional synchronization of the files, and we win
quite a reliable backup in the meantime :)
