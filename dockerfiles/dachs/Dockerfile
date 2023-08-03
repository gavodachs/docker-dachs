FROM debian:bookworm

LABEL Description=DaCHS\ is\ a\ publishing\ infrastructure\ for\ the\ Virtual\ Observatory. \
      Reference=http://arxiv.org/abs/1408.5733

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
# - gavo/beta (gavo/release + gavo/beta)
# - main (debian/main)
# * If not defined, default is 'main'
ARG INSTALL_REPO="${INSTALL_REPO:-main}"

ENV _APT_SOURCES="/etc/apt/sources.list.d/gavo.list"
COPY etc/apt_sources.list "$_APT_SOURCES"

# Some fixes on the environment
# ---
# This is the brute-force solution for Debian;
# I am having problems in set locales non-interactively,
# and since I really need the "C/UTF8" for postgres, will just set it for all.
ENV LC_ALL=C.UTF-8
RUN echo LC_ALL="$LC_ALL" > /etc/default/locale

RUN sed -i 's/exit 101/exit 0/' /usr/sbin/policy-rc.d
# ---

# Setup GAVO key, then repositories according to INSTALL_REPO
# RUN wget -qO - http://docs.g-vo.org/archive-key.asc | apt-key add -
RUN curl https://vo.ari.uni-heidelberg.de/debian/gavo-archive-keyring.asc \
    | tee /etc/apt/trusted.gpg.d/gavo-archive.keyring.asc

# If installing any version other than "main", backports is in there:
RUN [ "$INSTALL_REPO" != "main" ] \
      && sed -i '/deb.*backports/s/^#//' $_APT_SOURCES \
      || echo "NOT using debian/backports repo"

# If installing -- i.e, "beta" version -- uncomment gavo's release and beta repos
RUN [ "$INSTALL_REPO" = "gavo/beta" -o "$INSTALL_REPO" = "latest" -o "$INSTALL_REPO" = "gavo" ] \
      && sed -i '/deb.*heidelberg/s/^#//' $_APT_SOURCES \
      || echo "NOT using gavo beta/release repos"

RUN echo "Using the following repositories:" && grep "deb" $_APT_SOURCES

# Define some important env
ENV GAVO_ROOT="/var/gavo"
ENV GAVO_INPUTS="${GAVO_ROOT}/inputs"
ENV GAVO_SETTINGS="/etc/gavo.rc"
ENV GAVOSETTINGS="$GAVO_SETTINGS"

# Install the whole thing
RUN DEBIAN_FRONTEND='noninteractive'              && \
    apt-get update                                && \
    apt-get install -y gavodachs2-server          && \
    apt-get clean                                 && \
    gavo serve stop && service postgresql stop

## Read Dachs version from just-installed package
#RUN PKG_VERSION=$(dpkg -l $PKG_NAME | tail -n1 | tr -s ' ' | cut -d' ' -f2-3) \
#    && echo -e "#-#-#\nInstalled DaCHS version: ${PKG_VERSION}\n#-#-#"

COPY etc/gavo.rc "$GAVO_SETTINGS"

# Add a 'port' variable to env
ENV GAVO_PORT=8080
EXPOSE $GAVO_PORT

COPY bin/help.sh /help.sh
COPY bin/dachs.sh /dachs.sh
COPY bin/start.sh /start.sh

ENTRYPOINT ["/bin/bash"]
CMD ["--rcfile", "/help.sh"]
