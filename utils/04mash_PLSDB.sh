#!/bin/bash

# Descrption: identify TA associotiated reads 

usage() {
    echo Usage: $0 "[ -i INPUT.fastq ] [ -o OUTPUT.fasta ] [ -d OUTPUD_FOLDER ] [ -r PATH/TO/DATABASE.fasta ]"
    echo "  Example1: bash $0 -i SRR00001.fastq -o SRR00001-TA.fa -d test_out_dir -r TA_DB.fa "
}


while getopts "i:d:o:r:h" arg ; do
    case $arg in
	i)
	    echo input file $OPTARG
	    inf=$OPTARG
	    ;;
	o)
	    echo output file $OPTARG
	    ouf=$OPTARG
	    ;;
	d)
	    oud=$OPTARG
	    echo output path $OPTARG 
	    ;;
	r)
	    ref=$OPTARG
	    echo database file $OPTARG	
	    ;;
	h)
	    usage   
	    exit 
	    ;;
	?)
	    echo "unknown arguments"
	    usage
	    exit 1 ;;
    esac
done


function mash_screen {
  INF=$1 # queries 
  pool=$2 # subjects
  OUF=$3
  
  echo 
  echo [] `ls "$INF"`
  #echo [] `ls "$OUF"`
  echo []`ls "$pool"`

  [ ${#@} -ne 3 ] && "ERROR: more/less than 3 arguments given" && exit 

  if [ ! -f $INF.msh ];then 
    mash sketch $INF -o $INF.msh -p `nproc` # -r 
    mash sketch $pool -o $pool.msh -p `nproc` # -r 
  fi 
  # -r: input is a read set, this is ignore by adding -p para, I assume the  -r mode employs paralleling automatically
  # -p: cpu thread usage 
  # -o: output mash sketch 
   
  mash screen -p `nproc`  $INF.msh $pool > $OUF #$oud/test1.tsv
  mash screen -p `nproc`  $pool.msh $INF > "$OUF"2 #$oud/test2.tsv 
  # -w winner takes all mode 
  # -o o vlaue
  # -i mini identity 
  # -v max pvalue 
   
 ls $oud -lth  
}

mkdir -p $oud 
mash_screen $inf $ref $ouf 


