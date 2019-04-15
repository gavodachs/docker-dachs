FROM debian:jessie

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

RUN DEBIAN_FRONTEND='noninteractive'                    && \
    apt-get update                                      && \
    apt-get install -y sudo wget vim locales git gnupg  && \
    apt-get clean

ENV LANG=C.UTF-8
RUN echo LANG="$LANG" > /etc/default/locale

ENV PG_VERSION=9.4

RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main'   \
        > /etc/apt/sources.list.d/gavo.list                         && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN DEBIAN_FRONTEND='noninteractive'                                  && \
    apt-get update                                                    && \
    apt-get install -y python-gavodachs postgresql-${PG_VERSION}-q3c  && \
    apt-get clean

ENV GAVO_ROOT="/var/gavo"                       \
    GAVOSETTINGS="${GAVO_ROOT}/etc/gavo.rc"     \
    PGHOST="postgres"

RUN addgroup --system gavo                                          && \
    adduser --system --ingroup gavo gavo                            && \
    adduser --disabled-password --gecos "" --ingroup gavo dachsroot && \
    adduser --quiet gavo gavo                                       && \
    adduser --quiet dachsroot gavo                                  && \
    mkdir -m 775 "${GAVO_ROOT}"                                     && \
    chown dachsroot "${GAVO_ROOT}"

EXPOSE 80

COPY etc/gavo.rc "$GAVOSETTINGS"

COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/dachs.sh"]
