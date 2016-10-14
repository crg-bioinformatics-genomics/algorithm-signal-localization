#!/bin/bash
# bash signal-localization.sh <random_number> <email_address> <title> <type> <protein file> <transcript idlist>
echo $1 $2 $3 $4 $5 $6

set -e
#set -o pipeline

script_folder=$(pwd)
if [ -s tmp/$1 ]; then
	rm -fr tmp/$1
fi
mkdir tmp/$1
mkdir tmp/$1/outputs
for i in `awk '{print $0}' $6`;do
  ( cp -r template tmp/$1/$i
  cp lincrnas/$i.rna.fragm.seq.rna.lib tmp/$1/$i/interactions.U/combine_parallel/rna/

  cd   tmp/$1/$i
	bash run_signal_localization_case.sh $1 $2 $3 $4 $5 $6 $script_folder $i
	cd ../../../ ) &

done
wait
