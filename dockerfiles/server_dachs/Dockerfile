FROM debian:buster

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

# BUILD-time arguments; to use GAVO's "beta" repo, for instance,
# `docker build --build-arg APT_REPO=beta .`
ARG APT_REPO="release"

# Same for PostgreSQL-q3c plugin (consequently, PSQL db altogether)
ARG PG_VERSION=11
ENV PG_VERSION=${PG_VERSION}

RUN DEBIAN_FRONTEND='noninteractive'                    && \
    apt-get update                                      && \
    apt-get install -y wget vim locales gnupg2          && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8
RUN echo LANG="$LANG" > /etc/default/locale

RUN echo "deb http://vo.ari.uni-heidelberg.de/debian ${APT_REPO} main" \
        > /etc/apt/sources.list.d/gavo.list                         && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

# Default is the Python-3 packages under Dachs-2.
# If you want Dachs-1 Python(2) library, use 'python-gavodachs' instead
ENV PKG_NAME="python3-gavo"

RUN DEBIAN_FRONTEND='noninteractive'                                  && \
    apt-get update                                                    && \
    apt-get install -y ${PKG_NAME} postgresql-${PG_VERSION}-q3c  && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    apt-get upgrade -y ${PKG_NAME}


ENV GAVO_ROOT="/var/gavo"
ENV GAVO_INPUTS="${GAVO_ROOT}/inputs"
ENV GAVO_SETTINGS="/etc/gavo.rc"

RUN addgroup --system gavo                                          && \
    adduser --system --ingroup gavo gavo                            && \
    adduser --disabled-password --gecos "" --ingroup gavo dachsroot && \
    adduser --quiet gavo gavo                                       && \
    adduser --quiet dachsroot gavo                                  && \
    mkdir -m 775 "${GAVO_ROOT}"                                     && \
    chown dachsroot "${GAVO_ROOT}"

COPY etc/gavo.rc "$GAVO_SETTINGS"

EXPOSE 8080

COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/dachs.sh"]
