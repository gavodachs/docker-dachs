FROM debian:jessie

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

RUN DEBIAN_FRONTEND='noninteractive'            && \
    apt-get update                              && \
    apt-get install -y sudo wget vim locales    && \
    apt-get clean

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main'      > /etc/apt/sources.list.d/gavo.list  && \
    echo 'deb-src http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list.d/gavo.list  && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d

RUN DEBIAN_FRONTEND='noninteractive'    && \
    apt-get update                      && \
    apt-get install -y python-gavodachs && \
    apt-get clean                       && \
    service postgresql stop

RUN DEBIAN_FRONTEND='noninteractive'                                                                                && \
    service postgresql start                                                                                        && \
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

RUN sed -i 's/^\(host\).*/\1 = postgres/' /var/gavo/etc/dsn

COPY etc/gavo.rc /etc/gavo.rc
COPY bin/dachs.sh /dachs.sh

EXPOSE 8080

ENTRYPOINT ["/bin/bash --rcfile /dachs.sh"]
