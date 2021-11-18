FROM "debian:bullseye"

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos H Brandt <github:chbrandt>"

# Everyday tools
RUN DEBIAN_FRONTEND='noninteractive' \
    && apt-get update \
    && apt-get install -y \
      curl \
      git \
      gnupg2 \
      locales \
      procps \
      sudo \
      vim \
      wget \
    && apt-get clean

# BUILD argument for extra repositories (besides debian/stable) to install dachs.
# Options are:
# - backports (debian/backports)
# - beta (gavo/release + gavo/beta)
ARG INSTALL_REPO="${INSTALL_REPO:-stable}"

ENV REPO_RELEASE='deb http://vo.ari.uni-heidelberg.de/debian release main'
ENV REPO_BETA='deb http://vo.ari.uni-heidelberg.de/debian beta main'
ENV REPO_BACKPORT='deb http://deb.debian.org/debian bullseye-backports main contrib'

ENV APT_SOURCES="/etc/apt/sources.list.d/gavo.list"
COPY /etc/apt_sources.list "$APT_SOURCES"

ARG PG_VERSION=13
ENV PG_VERSION=${PG_VERSION}

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL=C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN [ "$INSTALL_REPO" = "backports" -o "$INSTALL_REPO" = "beta" ] \
      && sed -i '/deb.*backports/s/^#//' $APT_SOURCES \
      || echo "NOT using debian/backports repo"

RUN [ "$INSTALL_REPO" = "beta" ] \
      && sed -i '/deb.*heidelberg/s/^#//' $APT_SOURCES \
      || echo "NOT using gavo beta/release repos"

RUN echo "Using the following repositories:" && grep "deb" $APT_SOURCES

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

ENTRYPOINT ["/bin/bash"]
CMD ["--rcfile", "/serve.sh"]
