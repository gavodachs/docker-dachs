FROM debian:jessie

ENV DATA='/var/gavo/inputs/arihip'

RUN DEBIAN_FRONTEND='noninteractive'    && \
    apt-get update                      && \
    apt-get install -y curl             && \
    apt-get clean

RUN mkdir -p $DATA                                                          && \
    cd $DATA                                                                && \
    curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd  && \
    mkdir data                                                              && \
    cd data                                                                 && \
    curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz

VOLUME $DATA
