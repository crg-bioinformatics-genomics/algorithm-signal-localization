import sys, os,csv, getopt
import numpy as np


#use : python library_checker.py <library folder to check>

def main(argv):

    inter_file=sys.argv[1]
    rna_id=sys.argv[2]
    inter_file_handle=open(inter_file,'r')
    dictionary=dict()
    fr_list=[]
    writefile=open("input.raw.tmp",'w')
    fragments=open(rna_id,'w')
    for line in inter_file_handle:
        if line.startswith("#"):
            continue
        linelist=line.strip().split()

        startrna=int(linelist[1].split("_")[-1].split("-")[0])
        stoprna=int(linelist[1].split("_")[-1].split("-")[1])
        startprot=int(linelist[0].split("_")[-1].split("-")[0])
        stopprot=int(linelist[0].split("_")[-1].split("-")[1])

        prot_range=range(startprot,stopprot)

        catrapid_score=float(linelist[2])
        key=str(startrna)+" "+str(stoprna)
        lp=stopprot-startprot+1
        lr=stoprna-startrna+1

        if key not in dictionary:
            dictionary[key]=[]
        dictionary[key].append(catrapid_score)

    for key, value in dictionary.iteritems():
        fragments.writelines(key+'\n')
        fr_list.append((np.mean(value),np.std(value)))
    #fr_list.append((lp,lr))
    for r in fr_list:
        writefile.writelines(' '.join(map(str, (r)))+' ')
    writefile.writelines([str(0.00)+' ' for i in range(len(fr_list)*2,200)])
    writefile.writelines(' '.join(map(str, ((lp,lr))))+'\n')
    writefile.writelines([str(1.00)+' ' for i in range(0,100)])
    writefile.writelines('\n')





if __name__ == "__main__":

    main(sys.argv[1:])
