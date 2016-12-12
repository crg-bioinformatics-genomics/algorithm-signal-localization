#!/bin/bash
# bash signal-localization.sh <random_number> <email_address> <title> <type> <protein file> <transcript idlist><mode> <rnafolder>
echo $1 $2 $3 $4 $5 $6
echo $7
echo $8


mode=$7
rnafolder=$8

set -e
#set -o pipeline

script_folder=$(pwd)
if [ -s tmp/$1 ]; then
	rm -fr tmp/$1
fi
mkdir tmp/$1
cp -r template/outputs tmp/$1/outputs
for i in `awk '{print $0}' $6`;do

  (

	cp -r template tmp/$1/$i


	if [[ $mode == "custom" ]]
	then

				cd   tmp/$1/$i
				echo "Rna sequence processing and fragmentation"
				if [ ! -s rna/rna_seqs_oneline/ ]; then
					mkdir rna/rna_seqs_oneline/
				fi
				if [ ! -s rna/rna_seqs_fragmented ]; then
					mkdir rna/rna_seqs_fragmented
				fi
				sed 's/[\| | \\ | \/ | \* | \$ | \# | \? | \! ]/./g' $rnafolder/$i | awk '(length($1)>=1)' | awk '($1~/>/){gsub(" ", "."); printf "\n%s\t", $1} ($1!~/>/){gsub(/[Uu]/, "T", $1); printf "%s",toupper($1)}' | awk '(NF==2)' | head -1 | sed 's/>\.//g;s/>//g' | awk '{print substr($1,1,12)"_"NR, $2}' >  ./rna/rna_seqs_oneline/$i

				cd fragmentation
					echo "Custom Rna fragmentation"
					if [ ! -s ../rna.libraries.U/rna_seqs ]; then
						mkdir ../rna.libraries.U/rna_seqs
					fi
					mkdir ../rna.libraries.U/rna_seqs/1
					bash rna.job.cutter.sh ../rna/rna_seqs_oneline/$i > ../rna.libraries.U/rna_seqs/1/$i.rna.fragm.seq;
				cd ..

				echo "Custom rna library generation"

				cd rna.libraries.U/
					if [ ! -s outs ]; then
						mkdir outs
					fi
					bash job1.sh
				cd ..
				python library_checker.py $(pwd | awk '{print $0"/rna.libraries.U/outs/"}')
				cp rna.libraries.U/outs/$i.rna.fragm.seq.rna.lib interactions.U/combine_parallel/rna/
				cd ../../../

	fi
	if [[ $mode == "lincrnas" ]]
	then
		cp lincrnas/$i.rna.fragm.seq.rna.lib tmp/$1/$i/interactions.U/combine_parallel/rna/
		#cp eclip_selected_transcripts/$i.rna.fragm.seq.rna.lib tmp/$1/$i/interactions.U/combine_parallel/rna/
	fi

	cp $5 tmp/$1/$i/outputs/protfile
	prot_file=$(readlink -f tmp/$1/$i/outputs/protfile)

  cd   tmp/$1/$i
	bash run_signal_localization_case.sh $1 $2 $3 $4 $prot_file $6 $script_folder $i $mode
	cd ../../../ ) &

done
wait
