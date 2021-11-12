FROM httpd:bullseye

RUN DEBIAN_FRONTEND='noninteractive'      && \
    apt-get update                        && \
    apt-get install -y awstats            && \
    apt-get install -y vim less procps    && \
    apt-get clean

COPY /etc/awstats.conf /etc/awstats/awstats.conf.local

# Apache2, by default, is under /usr/local/apache2
#ENV HTTPD_PREFIX=/usr/local/apache2

COPY etc/apache2_awstats.conf $HTTPD_PREFIX/conf/awstats.conf
RUN echo "Include conf/awstats.conf" >> $HTTPD_PREFIX/conf/httpd.conf

# By default, Awstats uses '/var/lib/awstats' for its database.
# In 'httpd' apache is not run by 'www-data' but 'daemon',
# so Awstats data directory permissions have to be adjusted.
# To not change ownership, 'daemon' is included in 'www-data' group
# and write permission is conceeded to the group.
RUN usermod -a -G www-data daemon && \
    chmod g+w /var/lib/awstats/

COPY etc/apache2_ssi.conf $HTTPD_PREFIX/conf/ssi.conf
RUN echo "Include conf/ssi.conf" >> $HTTPD_PREFIX/conf/httpd.conf

#RUN a2enmod include.load && a2enmod cgi && a2enconf awstats

#COPY bin/entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/bin/bash", "--rcfile", "/entrypoint.sh"]
