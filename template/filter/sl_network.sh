#!/bin/bash
file=$1
case=$2
echo $case > tmp/names.txt
model=51
n_outputs=100
n_inputs=202
python prepare_nn_input.py $file $case $n_inputs $n_outputs
f="params.sl.theta"


#cat $f/min.relative.i.txt $f/max.relative.i.txt  input.raw.tmp  |   awk '(NR==1){for(i=1;i<=NF;i++){m[i]=$i}} (NR==2){for(i=1;i<=NF;i++){M[i]=$i}} (NR==3)&&(NF==1){m2[1]=$1} (NR==4)&&(NF==1){M2[1]=$1} (NR>4)&&(NF>1){for(i=1;i<=NF;i++){ s=0; if (m[i]!=M[i]){s=(($i-m[i])/(M[i]-m[i])-1/2)*2;} printf "%4.7f\t",s} printf "\n"} (NR>4)&&(NF==1){s=0; if (m2[1]!=M2[1]){s=(($1-m2[1])/(M2[1]-m2[1])-1/2)*2} print s}' >   tmp/norm.tmp
#awk '{a[NR]=$0} (NR%2==1){s=NF} END{printf "%i\t%i\t%i\n",NR/2,s, 100; for(i=1;i<=NR;i++){printf "%s\n",a[i]}}' tmp/norm.tmp > input.txt

cat $f/min.relative.i.$model.txt $f/max.relative.i.$model.txt  input.raw.tmp  |   awk '(NR==1){for(i=1;i<=NF;i++){m[i]=$i}} (NR==2){for(i=1;i<=NF;i++){M[i]=$i}} (NR>2)&&(NR%2!=0){for(i=1;i<=NF;i++){ s=0; if (m[i]!=M[i]){s=(($i-m[i])/(M[i]-m[i])-1/2)*2;} printf "%4.2f\t",s} printf "\n"} (NR>2)&&(NR%2==0){print $0}'  > tmp/norm.tmp
awk '{a[NR]=$0} (NR==1){s=NF} (NR==2){t=NF} END{printf "%i\t%i\t%i\n",NR/2,s, t; for(i=1;i<=NR;i++){printf "%s\n",a[i]}}' tmp/norm.tmp > input.txt

./scripts/sl_nnetwrok input.txt ./models/secondary.$model | awk '(NF==3)' > tmp/output.raw.txt
awk 'BEGIN { ORS=" " };{print $3}' tmp/output.raw.txt >tmp/output.raw.result.txt
echo "" >>tmp/output.raw.result.txt
awk '{print $1, $2}' tmp/output.raw.txt >tmp/output.raw.columns.txt
MG=$(cat $f/max.relative.global.txt)
cat $f/min.relative.o.$model.txt $f/max.relative.o.$model.txt  tmp/output.raw.result.txt |   awk '(NR==1){for(i=1;i<=NF;i++){m[i]=$i}} (NR==2){for(i=1;i<=NF;i++){M[i]=$i}}  (NR>2){for(i=1;i<=NF;i++){ s=0; s=(($i/2+1/2)*(M[i]-m[i])+m[i])/"'$MG'"; printf "%4.2f\t",s} printf "\n"}' >tmp/output.norm.txt
cat tmp/output.norm.txt | tr '\t' '\n' >tmp/tmp.1
paste -d " "  tmp/output.raw.columns.txt tmp/tmp.1 >tmp/output.raw.norm.final.txt
