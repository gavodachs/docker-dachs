FROM ubuntu:trusty

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y sudo wget vim locales && \
    apt-get clean

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
#ENV LC_ALL C.UTF-8
#RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

# I'll leave the lines below for further look;
# These work just find under Ubuntu.
# (Yeah, I'll remove these lines in the near future...probably...)
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_CTYPE C.UTF-8
RUN locale-gen --purge $LANG && \
    echo LANG="$LANG" > /etc/default/locale && \
    echo LANGUAGE="$LANGUAGE" >> /etc/default/locale && \
    echo LC_CTYPE="$LC_CTYPE" >> /etc/default/locale

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main' > /etc/apt/sources.list.d/gavo.list && \
    echo 'deb-src http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list.d/gavo.list && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d

RUN apt-get update                      && \
    apt-get install -y python-gavodachs && \
    apt-get clean                       && \
    service postgresql stop

RUN service postgresql start                                                                                        && \
    apt-get update                                                                                                  && \
    apt-get download gavodachs-server                                                                               && \
    DEBFILE=$(ls -1 gavodachs-server*)                                                                              && \
    dpkg-deb -R $DEBFILE tmp                                                                                        && \
    sed -i 's/\(su -s\/bin\/sh -c\)\("gavo init"\)\(.*\)/\1 "gavo init -d host=postgres" \3/' tmp/DEBIAN/postinst   && \
    dpkg-deb -b tmp $DEBFILE                                                                                        && \
    apt-get install -y gdebi-core                                                                                   && \
    gdebi --non-interactive $DEBFILE                                                                                && \
    apt-get clean                                                                                                   && \
    gavo serve stop && service postgresql stop

RUN service postgresql start && \
    PGFILE=$(su -l postgres -c "psql -t -P format=unaligned -c 'show hba_file;'") && \
    echo 'host  all  all  172.17.0.0/24  trust' >> $PGFILE && \
    echo "listen_addresses='*'" >> "${PGFILE%/*}/postgresql.conf" && \
    service postgresql stop

COPY etc/gavo.rc /etc/gavo.rc
COPY bin/dachs.sh /dachs.sh

EXPOSE 5432
#ENTRYPOINT ["/dachs.sh"]
ENTRYPOINT ["/bin/bash"]
