#!/bin/bash
file=$1
rna=$2
echo $rna > tmp/names.gs.txt

n_outputs=1
n_inputs=202
python prepare_nn_input.py $file $rna $n_inputs $n_outputs

mv input.raw.tmp input.gs.raw.tmp
f="params.globalscore"
cat $f/min.relative.i.txt $f/max.relative.i.txt  $f/min.relative.o.txt $f/max.relative.o.txt input.gs.raw.tmp   |   awk '(NR==1){for(i=1;i<=NF;i++){m[i]=$i}} (NR==2){for(i=1;i<=NF;i++){M[i]=$i}} (NR==3)&&(NF==1){m2[1]=$1} (NR==4)&&(NF==1){M2[1]=$1} (NR>4)&&(NF>1){for(i=1;i<=NF;i++){ s=0; if (m[i]!=M[i]){s=(($i-m[i])/(M[i]-m[i])-1/2)*2;} printf "%4.7f\t",s} printf "\n"} (NR>4)&&(NF==1){s=0; if (m2[1]!=M2[1]){s=(($1-m2[1])/(M2[1]-m2[1])-1/2)*2} print s}' >   tmp/norm.gs.tmp
awk '{a[NR]=$0} (NF!=1){s=NF} END{printf "%i\t%i\t%i\n",NR/2,s, 1; for(i=1;i<=NR;i++){printf "%s\n",a[i]}}' tmp/norm.gs.tmp > input.gs.txt
./scripts/test input.gs.txt ./models/secondary.80 | awk '(NF==3)' > tmp/output.gs.txt
