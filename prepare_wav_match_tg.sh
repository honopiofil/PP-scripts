#!/bin/bash

if [ $# -ne 3 ]; then
  echo "usage: prepare_wav_match_tg.sh [tg_dir] [wav_dir] [output_dir]"
  exit 0
fi

tg=$1
wav=$2
output=$3

for f in $tg/* ; do echo $(echo "$f" | sed 's|^.*tg\/||' | sed 's|\.TextGrid||') ; done | uniq > TGlist

awk '{ system("find '$wav'/ -name " $1 ".wav | xargs -I {} ln -srf {} '$output'/" )  }' TGlist

rm TGlist
