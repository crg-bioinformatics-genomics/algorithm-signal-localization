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
      echo "# protein / rna / raw score / dp " > ../../outputs/interactions.$1.$3.txt
      cat pre-compiled/* >> ../../outputs/interactions.$1.$3.txt
      mv pre-compiled/* pre-compiled/out.merged.posi.txt
cd ../../

cd filter

    echo "Global Score computing"
    date +"%m-%d-%y %r"
    awk '{print "protein_"$1,"rna_"$2,$3,$4}' ../interactions.U/combine_parallel/pre-compiled/out.merged.posi.txt > interactions.$1.$3.txt
    bash start.sh interactions.$1.$3.txt -1 > processed.txt
    awk '{printf "%.2f\n", ($2+1)/2}' processed.txt > ../outputs/filter.tmp

cd ../

#cd interactions.U/combine_parallel

#  echo "standalone 200 nega proteins and RNA interaction computing"
#  date +"%m-%d-%y %r"
#  mv pre-compiled/out.merged.posi.txt out.merged.posi.txt

#  prot_lib_folder=$(echo $script_folder | awk '{print $0"/nega.prot.libraries/"}')
#  python multiplier.py 10 $prot_lib_folder 'rna'
# cat pre-compiled/* > out.merged.nega.txt
#  rm -r pre-compiled/*
#  mv out.merged.nega.txt  pre-compiled/out.merged.nega.txt
#  mv out.merged.posi.txt  pre-compiled/out.merged.posi.txt

#  cd binding_sites
#    perl binding_sites.pl > table.txt

#    Lrna=$(grep $case $script_folder/positives_info.txt | awk '{print $2}')
#    Lfragm=$(grep $case $script_folder/positives_info.txt | awk '{print $3}')
    #Lrna=$(grep $case $script_folder/lincrnas_info.txt | awk '{print $2}')
    #Lfragm=$(grep $case $script_folder/lincrnas_info.txt | awk '{print $3}')
#    GS=$(awk '{print $1}' ../../../outputs/filter.tmp | head -1)
#    Rscript binding_sites.r table.txt "$Lrna" "$Lfragm" "$GS"
#    convert -density 300 -trim binding_sites.pdf -quality 100 -resize 900x231 binding_sites.png
#    cp binding_sites.png ../../../outputs/$case.binding_sites.png
#    awk '(NR>1)' smallTable.txt | sort -k5nr | awk 'BEGIN{printf "<tbody>\n"}{printf "\t<tr>\n\t\t<td>%s</td>\n\t\t<td>%s</td>\n\t\t<td>%s</td>\n\t\t<td>%.3f</td>\n\t</tr>\n", NR,$1"-"$2, $3"-"$4,$5}END{print """</tbody>"""}' > ../../../outputs/$case.binding_sites.html
#    cp smallTable.txt ../../../outputs/$case.smallTable.txt
#    cp bigTable.txt ../../../outputs/$case.bigTable.txt

#cd ../../../
#cp outputs/$case.binding_sites.html ../outputs/
#cp outputs/$case.smallTable.txt ../outputs/
#cp outputs/$case.bigTable.txt ../outputs/
#cp outputs/$case.binding_sites.png ../outputs/

cp outputs/filter.tmp ../outputs/$case.filter.tmp
cd ../
rm -r $case
#cp outputs/interactions.$1.$3.txt ../outputs/$case.interactions.$1.$3.txt
