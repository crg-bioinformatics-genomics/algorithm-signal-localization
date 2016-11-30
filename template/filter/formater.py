import sys, os,csv, getopt
import numpy as np


#use : python library_checker.py <library folder to check>

def main(argv):

    inputfile=sys.argv[1]
    length=int(sys.argv[2])
    input_handle=open(inputfile,'r')
    values=[]
    fragms=[]
    predicted=[]
    for line in input_handle:
        start=int(line.split()[0])
        stop=int(line.split()[1])
        val=float(line.split()[2])

        fragms.append(str(line.split()[0])+" "+str(line.split()[1]))
        values.append(float(line.split()[2].strip()))
        predicted.append((start, stop, val))


    vector_dict_nt,new_predicted=nt_vector(predicted, length)

    for np in new_predicted:
        print ' '.join(map(str, (np)))



def nt_vector(predicted, length):
    vector_nt=np.zeros(shape=(length,1))
    new_predicted=[]
    vector_dict_nt=dict()


    for pr_bs in predicted:
        pr_range=range(pr_bs[0],pr_bs[1])

        for i in pr_range:
            if i not in vector_dict_nt:
                vector_dict_nt[i]=[]
            vector_dict_nt[i].append(pr_bs[2])

    for key, values in vector_dict_nt.items():
        vector_dict_nt[key]=np.mean(values)
    for i in range(1,length+1):
        if i not in vector_dict_nt:
            vector_dict_nt[i]='nan'
    start=1
    stop=1
    val=vector_dict_nt[1]
    for i in range(1,length+1):
        if val==vector_dict_nt[i]:
            stop=i
        else:
            stop=i
            new_predicted.append((start,stop,val))

            start=i

            val=vector_dict_nt[i]
    new_predicted.append((start,stop,val))

    return vector_dict_nt,new_predicted



if __name__ == "__main__":

    main(sys.argv[1:])
