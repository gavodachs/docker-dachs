FROM httpd:bullseye

RUN DEBIAN_FRONTEND='noninteractive'      && \
    apt-get update                        && \
    apt-get install -y awstats            && \
    apt-get clean

COPY /etc/awstats.conf /etc/awstats/awstats.conf.local

#ENV APACHE_ROOT=/usr/local/apache2

COPY etc/apache2_awstats.conf $HTTPD_PREFIX/conf/awstats.conf
RUN echo "Include conf/awstats.conf" >> $HTTPD_PREFIX/conf/httpd.conf

COPY etc/apache2_ssi.conf $HTTPD_PREFIX/conf/ssi.conf
RUN echo "Include conf/ssi.conf" >> $HTTPD_PREFIX/conf/httpd.conf

#RUN a2enmod include.load && a2enmod cgi && a2enconf awstats
RUN a2enconf awstats

#COPY bin/entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/bin/bash", "--rcfile", "/entrypoint.sh"]
