ARG DEBIAN_IMAGE="bullseye"

FROM "debian:$DEBIAN_IMAGE"

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

# BUILD-time arguments; to use GAVO's "beta" repo, for instance,
# `docker build --build-arg APT_REPO=beta .`
ARG APT_REPO="release"

# BUILD-time arguments; to use a different version of Postgers
ARG PG_VERSION=11
ENV PG_VERSION=${PG_VERSION}

RUN DEBIAN_FRONTEND='noninteractive' \
    && apt-get update \
    && apt-get install -y \
      curl \
      git \
      gnupg2 \
      locales \
      sudo \
      vim \
      wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL=C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN echo "deb http://vo.ari.uni-heidelberg.de/debian ${APT_REPO} main" \
        > /etc/apt/sources.list.d/gavo.list                         && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN DEBIAN_FRONTEND='noninteractive'                                && \
    apt-get update                                                  && \
    apt-get install -y postgresql-$PG_VERSION                       && \
    apt-get install -y postgresql-$PG_VERSION-pgsphere              && \
    apt-get install -y postgresql-$PG_VERSION-q3c                   && \
    apt-get clean

RUN PGFILE=/etc/postgresql/${PG_VERSION}/main/pg_hba.conf           && \
    echo 'host  all  all  172.17.0.0/24  trust' >> $PGFILE          && \
    echo "listen_addresses='*'" >> "${PGFILE%/*}/postgresql.conf"

RUN PGDATA=/var/lib/postgresql/${PG_VERSION}                            \
    mkdir -p -m 777 /var/run/postgresql/${PG_VERSION}-main.pg_stat_tmp/ && \
    su - postgres  -c "/usr/lib/postgresql/${PG_VERSION}/bin/postgres   \
      -c config_file=/etc/postgresql/${PG_VERSION}/main/postgresql.conf \
      -c logging_collector=on"                                          & \
    sleep 5                                                             && \
    su postgres -c "createuser -s dachsroot"                            && \
    su postgres -c "createuser -s root"                                 && \
    su postgres -c "createdb gavo"

EXPOSE 5432

COPY bin/serve.sh /serve.sh

CMD ["/bin/bash", "--rcfile", "/serve.sh"]
