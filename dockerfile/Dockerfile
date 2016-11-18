FROM debian:jessie

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

ENV PG_VERSION 9.4

RUN DEBIAN_FRONTEND='noninteractive'               && \
    apt-get update                                 && \
    apt-get install -y sudo wget vim locales git   && \
    apt-get clean

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main'      > /etc/apt/sources.list.d/gavo.list  && \
    echo 'deb-src http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list.d/gavo.list  && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add - \
		DEBIAN_FRONTEND='noninteractive'                                  && \
    	apt-get update                                                  && \
    	apt-get install -y postgresql-$PG_VERSION                       && \
    	apt-get install -y postgresql-$PG_VERSION-pgsphere              && \
    	apt-get install -y postgresql-$PG_VERSION-q3c                   && \
    	apt-get clean

RUN PGFILE=/etc/postgresql/$PG_VERSION/main/pg_hba.conf && \
    echo 'host  all  all  172.17.0.0/24  trust' >> $PGFILE && \
    echo "listen_addresses='*'" >> "${PGFILE%/*}/postgresql.conf"

RUN PGDATA=/var/lib/postgresql/9.4 \
	mkdir -p -m 777 /var/run/postgresql/9.4-main.pg_stat_tmp/ \
	su - postgres  -c "/usr/lib/postgresql/9.4/bin/postgres \
		-c config_file=/etc/postgresql/9.4/main/postgresql.conf \
		-c logging_collector=on" & \
	sleep 5 # Ouch: wait for postgres to come up.  Better way?  \
	su postgres -c "createuser -s dachsroot" \
	su postgres -c "createdb gavo" \


EXPOSE 5432

COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/dachs.sh"]
