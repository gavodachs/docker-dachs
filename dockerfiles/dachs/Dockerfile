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

# BUILD argument for extra repositories (besides debian/main) to install dachs.
# Options are:
# - backports (debian/backports)
# - beta (gavo/release + gavo/beta)
ARG INSTALL_REPO="${INSTALL_REPO:-main}"

ENV REPO_RELEASE='deb http://vo.ari.uni-heidelberg.de/debian release main'
ENV REPO_BETA='deb http://vo.ari.uni-heidelberg.de/debian beta main'
ENV REPO_BACKPORT='deb http://deb.debian.org/debian bullseye-backports main contrib'

ENV APT_SOURCES="/etc/apt/sources.list.d/gavo.list"
COPY /etc/apt_sources.list "$APT_SOURCES"

# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL=C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d

RUN wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -

RUN [ "$INSTALL_REPO" = "backports" -o "$INSTALL_REPO" = "beta" ] \
      && sed -i '/deb.*backports/s/^#//' $APT_SOURCES \
      || echo "NOT using debian/backports repo"

RUN [ "$INSTALL_REPO" = "beta" ] \
      && sed -i '/deb.*heidelberg/s/^#//' $APT_SOURCES \
      || echo "NOT using gavo beta/release repos"

RUN echo "Using the following repositories:" && grep "deb" $APT_SOURCES

RUN DEBIAN_FRONTEND='noninteractive'              && \
    apt-get update                                && \
    apt-get install -y gavodachs2-server          && \
    apt-get clean                                 && \
    gavo serve stop && service postgresql stop

#RUN PKG_VERSION=$(dpkg -l $PKG_NAME | tail -n1 | tr -s ' ' | cut -d' ' -f2-3) \
#    && echo -e "#-#-#\nInstalled DaCHS version: ${PKG_VERSION}\n#-#-#"

ENV GAVO_ROOT="/var/gavo"
ENV GAVO_INPUTS="${GAVO_ROOT}/inputs"
ENV GAVO_SETTINGS="/etc/gavo.rc"

ENV GAVOSETTINGS="$GAVO_SETTINGS"
COPY etc/gavo.rc "$GAVOSETTINGS"

ENV GAVO_PORT=8080
EXPOSE $GAVO_PORT

COPY bin/help.sh /dachs/help.sh
COPY bin/dachs.sh /dachs.sh

CMD ["/bin/bash", "--rcfile", "/dachs/help.sh"]
