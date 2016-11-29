#!/bin/bash
script_folder=$7
case=$8
./flip -u $5
sed 's/[\| | \\ | \/ | \* | \$ | \# | \? | \! ]/./g' $5 | awk '(length($1)>=1)' | awk '($1~/>/){gsub(" ", "."); printf "\n%s\t", $1} ($1!~/>/){printf "%s", toupper($1)}' | awk '(NF==2)' | head -1 | sed 's/>\.//g;s/>//g' | awk '{print substr($1,1,12)"_"NR, toupper($2)}' >  ./protein/outfile

if [[ ! -s "./protein/outfile" ]]; then
        echo "Protein file has not been created."
  exit 1
fi
echo "# Reference Sequences" >  ./outputs/yoursequences.$1.$3.txt
cat ./protein/outfile  	    >>  ./outputs/yoursequences.$1.$3.txt


num2=`cat ./protein/outfile  | awk '{print NR}'`

echo "Protein sequence processing and fragmentation"
date +"%m-%d-%y %r"

cp protein/outfile fragmentation/outfile
cd fragmentation
  bash protein.job.cutter.sh outfile > ../protein/outfile.fr
cd ../

  # RNA LIBRARY GENERATION ######################################################################################
echo "Protein library generation"
date +"%m-%d-%y %r"

cd protein.libraries.U
  cd protein_library_generator/
    sed 's/|/_/g' ../../protein/outfile.fr > outfile.fr.txt
    bash rungenerator.protein.sh outfile.fr.txt
    mv outfile.fr.prot.lib ../../outputs/protein.library.$1.$3.txt

  cd ../
cd ../

# PROTEIN + RNA INTERACTIONS #################################################################################

echo "protein and RNA interaction computing"
date +"%m-%d-%y %r"

cd interactions.U/
  cp ../outputs/protein.library.$1.$3.txt combine_parallel/prot/prot.lib

    cd combine_parallel/
      if [ ! -s pre-compiled ]; then
        mkdir pre-compiled/
      fi


      python multiplier.py 10 "prot" "rna"
      echo "#protein / rna / raw score / dp " > ../../outputs/interactions.$1.$3.txt
      cat pre-compiled/* >> ../../outputs/interactions.$1.$3.txt
      #mv pre-compiled/* pre-compiled/out.merged.posi.txt
    cd ../
cd ../
cd filter

    echo "Signal Localisation computing"

    date +"%m-%d-%y %r"
    bash sl_network.sh ../outputs/interactions.$1.$3.txt > $case.processed.txt
    echo $case $(awk '{printf "%.2f\n", ($2+1)/2}' $case.processed.txt) > ../filter.processed.txt
cd ../

cd ../
