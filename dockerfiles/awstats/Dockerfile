FROM debian:bullseye

RUN DEBIAN_FRONTEND='noninteractive'      && \
    apt-get update                        && \
    apt-get install -y apache2 awstats    && \
    apt-get clean

COPY etc/apache2_awstats.conf /etc/apache2/conf-available/awstats.conf
COPY /etc/awstats.conf /etc/awstats/awstats.conf.local

RUN a2enmod include.load && a2enmod cgi && a2enconf awstats

COPY bin/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "--rcfile", "/entrypoint.sh"]
