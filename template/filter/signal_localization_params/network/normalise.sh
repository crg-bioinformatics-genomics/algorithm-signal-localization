echo "sequence features..."
awk 'BEGIN{for(i=1;i<=10000;i++){minl[i]=10000; mins[i]=10000; maxl[i]=-10000; maxs[i]=-10000;} mints=10000; maxts=-10000; maxtl=-10000; mintl=10000}
{
if(NR%2!=0){for(i=1;i<=NF;i++){a[NR,i]=$i;  if(mins[i]>$i){mins[i]=$i;}  if(maxs[i]<$i){maxs[i]=$i;} if(mints>$i){mints=$i} if(maxts<$i){maxts=$i}} s=NF;} 
}
END{
{for(j=1;j<=s;j++){print mins[j], maxs[j], mints, maxts;} printf"\n";} 
}' input/$1 > input/seq.min.max.dat;
#
echo "output   features..."
awk 'BEGIN{for(i=1;i<=10000;i++){minl[i]=10000; mins[i]=10000; maxl[i]=-10000; maxs[i]=-10000;} mints=10000; maxts=-10000; maxtl=-10000; mintl=10000}
{
if(NR%2==0){for(i=1;i<=NF;i++){b[NR,i]=$i;  if(minl[i]>$i){minl[i]=$i;}  if(maxl[i]<$i){maxl[i]=$i;} if(mintl>$i){mintl=$i} if(maxtl<$i){maxtl=$i}} l=NF;}
}
END{
{for(j=1;j<=l;j++){print minl[j], maxl[j], mintl, maxtl;} printf"\n";} 
}' input/$1 > input/el.min.max.dat;
#
echo "scaling variables..."
awk 'BEGIN{for(i=1;i<=10000;i++){minl[i]=10000; mins[i]=10000; maxl[i]=-10000; maxs[i]=-10000;}  mints=10000; maxts=-10000; maxtl=-10000; mintl=10000}
{
if(NR%2!=0){for(i=1;i<=NF;i++){a[NR,i]=$i;  if(mins[i]>$i){mins[i]=$i;}  if(maxs[i]<$i){maxs[i]=$i;} if(mints>$i){mints=$i} if(maxts<$i){maxts=$i}} s=NF;  } 
if(NR%2==0){for(i=1;i<=NF;i++){b[NR,i]=$i;  if(minl[i]>$i){minl[i]=$i;}  if(maxl[i]<$i){maxl[i]=$i;} if(mintl>$i){mintl=$i} if(maxtl<$i){maxtl=$i}} l=NF;  }
}
END{
#print "#" mints, maxts, mintl, maxtl; 
print NR/2 , s,l;
for(i=1;i<=NR;i++){
if(i%2!=0){for(j=1;j<=s;j++){f=1; if(j>1){f=maxs[j]/maxts; f=1} if(mins[j]!=maxs[j]){printf "%9.7f ", ((a[i,j]-mins[j])/(maxs[j]-mins[j])-1/2)*2*f ;}
                             if(mins[j]==maxs[j]){printf "%9.7f ", mins[j];}}
			      printf"\n";}

if(i%2==0){for(j=1;j<=l;j++){f=1; if(j>1){f=maxl[j]/maxtl; f=1} if(minl[j]!=maxl[j]){printf "%9.7f ", ((b[i,j]-minl[j])/(maxl[j]-minl[j])-1/2)*2*f ;} 
                             if(minl[j]==maxl[j]){printf "%9.7f ", minl[j];}}
			     printf"\n";}
}
}' input/$1 >  normalisation/normalised.dat;
echo "building matrices..."
awk '{ if(NR==1){print $1-"'$2'", $2, $3;} if(NR>1){a[NR]=$0; k++;}}  END{for(i=2;i<=k-2*"'$2'"+1;i++){    print a[i];}}'   normalisation/normalised.dat >  ./input/train.$3.dat
awk '{ if(NR==1){print "'$2'", $2, $3;}    if(NR>1){a[NR]=$0; k++;}}  END{for(i=k-2*"'$2'"+2;i<=k+1;i++){print a[i];}}'     normalisation/normalised.dat >  ./input/test.$3.dat
