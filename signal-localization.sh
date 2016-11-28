#!/bin/bash
# bash signal-localization.sh <random_number> <email_address> <title> <type> <protein file> <transcript idlist>
echo $1 $2 $3 $4
echo $5
echo $6


set -e
#set -o pipeline

script_folder=$(pwd)
if [ -s tmp/$1 ]; then
	rm -fr tmp/$1
fi
mkdir tmp/$1
cp -r template/outputs tmp/$1/outputs
for i in `awk '{print $0}' $6`;do

  ( cp -r template tmp/$1/$i

	#cp eclip_selected_transcripts/$i.rna.fragm.seq.rna.lib tmp/$1/$i/interactions.U/combine_parallel/rna/
  cp lincrnas/$i.rna.fragm.seq.rna.lib tmp/$1/$i/interactions.U/combine_parallel/rna/
	cp $5 tmp/$1/$i/outputs/protfile
	prot_file=$(readlink -f tmp/$1/$i/outputs/protfile)

  cd   tmp/$1/$i
	bash run_signal_localization_case.sh $1 $2 $3 $4 $prot_file $6 $script_folder $i
	cd ../../../ ) &

done
wait
