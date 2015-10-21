FROM ubuntu:trusty

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_CTYPE C.UTF-8

RUN locale-gen --purge $LANG && \
    echo LANG="$LANG" > /etc/default/locale && \
    echo LANGUAGE="$LANGUAGE" >> /etc/default/locale && \
    echo LC_CTYPE="$LC_CTYPE" >> /etc/default/locale

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y sudo wget vim && \
    apt-get clean

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main' > /etc/apt/sources.list.d/gavo.list && \
    echo 'deb-src http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list.d/gavo.list && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d

RUN apt-get update && \
    apt-get install -y gavodachs-server && \
    apt-get clean

COPY etc/gavo.rc /etc/gavo.rc
COPY bin/dachs.sh /dachs.sh

EXPOSE 8080
ENTRYPOINT ["/dachs.sh"]
