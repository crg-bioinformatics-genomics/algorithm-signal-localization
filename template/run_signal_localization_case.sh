#!/bin/bash
script_folder=$7
case=$8
mode=$9
./flip -u $5
threshold=-0.2
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

      cat pre-compiled/* >> ../../outputs/interactions.$1.$3.txt
    cd ../
cd ../
cd filter

    echo "Global Score computing"
    date +"%m-%d-%y %r"
    awk '{print "protein_"$1,"rna_"$2,$3,$4}' ../outputs/interactions.$1.$3.txt > interactions.$1.$3.txt
    bash gs_network.sh interactions.$1.$3.txt $case
    paste tmp/names.gs.txt tmp/output.gs.txt | awk '{print $1, $NF}'> processed.txt
    awk '{printf "%.2f\n", ($2+1)/2}' processed.txt > ../outputs/$case.filter.tmp

    echo "Signal Localisation computing"
    if [[ $mode == "lincrnas" ]]
  	then
      Lrna=$(grep $case $script_folder/lincrnas_info.txt | awk '{print $2}')
    fi
    if [[ $mode == "custom" ]]
  	then
      Lrna=$(awk '{print length($2)}' ../rna/rna_seqs_oneline/$case)
    fi
    date +"%m-%d-%y %r"
    bash sl_network.sh ../outputs/interactions.$1.$3.txt $case
    paste -d " "  $case tmp/output.raw.norm.final.txt | awk '(NF>3){printf "%s %s %.7f\n", $1, $2 , $NF}' > tmp/output.txt
    echo "#startRNA  stopRNA scoreRaw" > ../outputs/$case.fragments.score.txt
    python formater.py tmp/output.txt $Lrna>> ../outputs/$case.fragments.score.txt
    thr=$(cat threshold.norm)


cd ../
  awk '(NR>1)&&($3!="nan")' ./outputs/$case.fragments.score.txt | sort -k3nr | awk 'BEGIN{printf "<tbody>\n"}{if ($3 >="'$thr'") class="red" ; else class="white" fi; printf "\t<tr class=\"%s\">\n\t\t<td>%s</td>\n\t\t<td>%s</td>\n\t\t<td>%.3f</td>\n\t</tr>\n", class,NR,$1"-"$2, $3}END{print """</tbody>"""}' > ./outputs/$case.binding_sites.html
  awk '($3!="nan"){print $0}' ./outputs/$case.fragments.score.txt >tmp.1
  mv tmp.1 ./outputs/$case.fragments.score.txt
  Rscript plotter.r ./outputs/$case.fragments.score.txt
  convert -density 300 -trim binding_sites.pdf -quality 100 -resize 900x231 binding_sites.png
  mv binding_sites.png ./outputs/$case.binding_sites.png
  cp -r ./outputs/* ../outputs/
cd ../
