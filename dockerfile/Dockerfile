FROM debian:stretch

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

ENV PG_VERSION 9.6

RUN DEBIAN_FRONTEND='noninteractive'               && \
    apt-get update                                 && \
    apt-get install -y sudo wget vim locales git gnupg  && \
    apt-get clean

ENV LANG C.UTF-8
RUN echo LANG="$LANG" > /etc/default/locale

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian release main'      > /etc/apt/sources.list.d/gavo.list  && \
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
    su postgres -c "createdb gavo"


EXPOSE 5432

COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/dachs.sh"]
