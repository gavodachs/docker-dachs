FROM debian:buster

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Author=Markus\ Demleitner \
      URL=http://docs.g-vo.org/DaCHS \
      Reference=http://arxiv.org/abs/1408.5733

MAINTAINER "Carlos Brandt <carloshenriquebrandt at gmail>"

# BUILD-time arguments; to use GAVO's "beta" repo, for instance,
# `docker build --build-arg APT_REPO=beta .`
ARG APT_REPO="release"

# To build for dachs-v1 use ('--build-arg') PKG_NAME=gavodachs-server
# Default now is DaCHS-v2!
ARG PKG_NAME="gavodachs2-server"

RUN DEBIAN_FRONTEND='noninteractive'                     && \
    apt-get update                                       && \
    apt-get install -y sudo wget vim locales git gnupg2  && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL=C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d

RUN echo "deb http://vo.ari.uni-heidelberg.de/debian release main"     \
        > /etc/apt/sources.list.d/gavo.list                         && \
    wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN [ "$APT_REPO" != "release" ] || echo "Using only 'release' deb/repo" && \
    echo "deb http://vo.ari.uni-heidelberg.de/debian ${APT_REPO} main"      \
        >> /etc/apt/sources.list.d/gavo.list                             && \
    echo "Using also '$APT_REPO' deb/repo"

RUN DEBIAN_FRONTEND='noninteractive'              && \
    apt-get update                                && \
    apt-get install -y "$PKG_NAME"                && \
    apt-get clean && rm -rf /var/lib/apt/lists/*  && \
    gavo serve stop && service postgresql stop

#RUN PKG_VERSION=$(dpkg -l $PKG_NAME | tail -n1 | tr -s ' ' | cut -d' ' -f2-3) \
#    && echo -e "#-#-#\nInstalled DaCHS version: ${PKG_VERSION}\n#-#-#"

ENV GAVO_ROOT="/var/gavo"
ENV GAVO_INPUTS="${GAVO_ROOT}/inputs"
ENV GAVO_SETTINGS="/etc/gavo.rc"

COPY etc/gavo.rc "$GAVO_SETTINGS"

EXPOSE 8080

COPY bin/help.sh /help.sh
COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/help.sh"]
