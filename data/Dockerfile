FROM debian:buster

ENV DATA='/var/gavo/inputs/arihip'

ADD download_arihip.sh /tmp/arihip.sh

RUN DEBIAN_FRONTEND='noninteractive'    && \
    apt-get update                      && \
    apt-get install -y curl             && \
    apt-get clean

RUN bash /tmp/arihip.sh $DATA

VOLUME $DATA
