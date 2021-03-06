#***************************************************************************
#                             catRAPID 
#                             -------------------
#    begin                : Nov 2010
#    copyright            : (C) 2010 by G.G.Tartaglia
#    author               : : Tartaglia
#    date                 : :2010-11-25
#    id                   : caRAPID protein-RNA interactions
#    email                : gian.tartaglia@crg.es
#**************************************************************************/
#/***************************************************************************
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# ***************************************************************************/
#!/bin/bash
awk ' {for(i=1;i<=length($1);i++){r[i]=substr($1,i,1)}} END{
for(i=1;i<=length($1);i++){if(r[i]=="A"){vdw=0.37+0.46+0.32+0.19+0.25+0.17+0.39+0.29+0.23+0.13;    h=0.11+0.08+0.19+0.05;}
                           if(r[i]=="G"){vdw=0.12+0.33+0.11+0.17+0.1+0.09+0.3+0.22+0.2+0.09; h=0.09+0.39+0.03+0.18+0.13;} 
			   if(r[i]=="C"){vdw=0.08+0.26+0.58+0.25+0.18+0.3+0.23+0.11;          h=0.29+0.13+0.16;} 
			   if(r[i]=="U"){vdw=0.19+0.3+0.54+0.39+0.32+0.49+0.32+0.18;          h=0.16+0.18+0.16} 
			   print i, vdw/2.8, h/0.82}}' $1 > ../tmp/vdw.2.tmp
awk '{a[NR]=$2; b[NR]=$3} END{
			   print 1, a[1]/1.5, b[1]/1.5; print 2, (a[1]+a[2]+a[3])/3.5, (b[1]+b[2]+b[3])/3,5 ;  print 3, (a[1]+a[2]+a[3]+a[4]+a[5])/5.5, (b[1]+b[2]+b[3]+b[4]+b[5])/5.5 ; 
			   for(i=1+3;i<=NR-3;i++){print i,(a[i-3]+a[i-2]+a[i-1]+a[i]+a[i+1]+a[i+2]+a[i+3])/7, (b[i-3]+b[i-2]+b[i-1]+b[i]+b[i+1]+b[i+2]+b[i+3])/7;} 
			   print NR-2, (a[NR-2]+a[NR-3]+a[NR-4]+a[NR-1]+a[NR])/5.5,  (b[NR-2]+b[NR-3]+b[NR-4]+b[NR-1]+b[NR])/5.5; print NR-1,  (a[NR-1]+a[NR-2]+a[NR])/3.5, (b[NR-1]+b[NR-2]+b[NR])/3.5;
			   print NR, a[NR]/1.5, b[NR]/1.5}' ../tmp/vdw.2.tmp
