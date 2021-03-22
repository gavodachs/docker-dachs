#!/bin/bash
set -ue

[[ $# == 2 ]] || { echo "Usage: $BASH_SOURCE <RD> </path/output>"; exit 2; }

RD=$1
OUTDIR=$2

cd $OUTDIR \
  && mkdir -p $RD/data \
  && cd $RD \
  && curl -O http://svn.ari.uni-heidelberg.de/svn/gavo/hdinputs/arihip/q.rd \
  && cd data \
  && curl -O http://dc.g-vo.org/arihip/q/cone/static/data.txt.gz
