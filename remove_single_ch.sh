#!/bin/bash

if [ $# -ne 3 ]; then
  echo "usage: remove_single_ch.sh [ctm] [final_ctm] [output]"
  exit 0
fi

ctm=$1
final_ctm=$2
output=$3

cut -d' ' -f1 $ctm | sort | uniq > temp_ch
sed 's|-[AB]$||' temp_ch | sort | uniq > temp_fl

for i in `cat temp_fl` ; do if [ `grep -c $i temp_ch` -ne 2 ] ; then echo $i ; fi ; done > single_ch
echo "Following files contains data for single channel and will not be copied from "$final_ctm "to" $output ":"
cat single_ch

cp $final_ctm $output

for l in `cat single_ch` ; do sed -i "/$l/d" $output ; done

rm temp_ch temp_fl single_ch
