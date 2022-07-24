#!/bin/bash
set -e 


# Description 
#   the input should be output generated from 01fastp.sh or raw/clean read data 
#   the output is contig fasta file

# Functions: 
#   get parameters 
#   detect the input file numbers, set pair ended 
#   check input file formats
#   main run
#   check run is complete or not, delete tmp files if yes, return else

# Version: 0.1.2 
# Update: 2022-06-08

usage() {
  echo Usage: $0 [ -i INPUT.R1.fastq,INPUT.R2.fastq ] [ -d PATH/TO/OUTPUT_FOLDER ] [ -t CPU_threads -o PATH/TO/OUTPUT_FILE ]
  echo "  Example1: bash scripts/02spades.sh -i /mnt/e/sra_data/SRR11252610_1.fastq,/mnt/e/sra_data/SRR11252610_2.fastq -d test_out/02spades_out -t 8 $'\n' -o test_oud/02spades_out/SRR11252610.scaffolds.fa "
  echo "  Example2: bash scripts/02spades.sh -i /mnt/e/sra_data/SRR11252610.fastq -d test_out/02spades_out -t 8 $'\n' -o test_oud/02spades_out/SRR11252610.scaffolds.fa"
}

check_para() {
  # check the total number of provided read data, automatically set -s/-1/-2 parameters 
  # set basename as the prefix of final output
  echo $'\n'PARAMETERS CHECKING
  INF=$1 
  #echo INF $INF
  fq_count=`echo $INF | awk -F',' 'END{print NF}'`
  if [ $fq_count -eq 1 ];then
    label='S' # single ended
    fn=${INF##*/} ; bn=${fn%.*}
    #echo filename $fn
    #echo basename $bn
  elif [ $fq_count -eq 2 ]; then
    label='P' # pair ended
    fq1=`echo $INF | cut -f1 -d','`
    fq2=`echo $INF | cut -f2 -d','`
    fn=${fq1##*/} ; bn=${fn%.*}
    #echo filename $fn
    #echo basename $bn
  elif [ $fq_count -ge 3 ] ;then
    label='U' # unpair multiple input
    fq=$INF # with more than 2 files
    fq1=`echo $INF | cut -f1 -d','` # only named with the 1st read data
    fn=${fq1##/*} ; bn=${fn%.*}
    #echo basename $bn
  fi
  echo input file count: $fq_count
  echo Running mode set to $label $'\n'
}

run_pe() {
  echo RUNNING WITH PAIR ENDED DATA    
  # run pair ended data
  FQ1=$1
  FQ2=$2
  OUD=$3
  BN=$4
  TH=$5
  echo run_pe TH $TH
  spades.py -1 $FQ1 -2 $FQ2 -o $OUD/$BN \
            -t $TH -k 17 --only-assembler
	    #7,9,11,13,15,17 #--only-assembler 
            #--meta --plasmid
}

run_se() {
  # run single ended data 
  echo RUNNING WITH SINGLE ENDED DATA
  INF=$1
  OUD=$2
  BN=$3
  TH=$4
  echo $INF $OUD $BN $TH
  echo run_se TH $TH
  spades.py -s $INF -o $OUD/$BN \
            -t $TH -k 17 --only-assembler 
            #--meta --plasmid 
}

del_tmp() {
  # delete tmp files
  if [ -f $oud/$bn/scaffolds.fasta ]; then 
    cp $oud/$bn/scaffolds.fasta $outfile 
    rm -f -r $oud/$bn
  fi
}

main() {
echo MAIN RUN
if [ "$label" == 'P' ];then
  echo '$fq1 $fq2 $oud $bn $th'
  echo $fq1 $fq2 $oud $bn $th
  run_pe $fq1 $fq2 $oud $bn $th

elif [ "$label" == 'S' ];then
  echo '$inf $oud $bn $th'
  echo $inf $oud $bn $th
  run_se $inf $oud $bn $th
fi
}

[ $# -eq 0 ] && echo ERROR: No arguments provided$'\n' && usage && exit

echo $'\n'GETTING OPTIONS
while getopts "i:o:d:t:" arg ; do 
  case $arg in 
    i)
      echo input file $OPTARG
      inf=$OPTARG 
      check_para $inf
      echo label $label
      ;;
    o)
      echo output file $OPTARG
      outfile=$OPTARG 
      echo output file $outfile 
      ;;
    d)
      echo output dir $OPTARG
      oud=$OPTARG
      ;;
    t)
      th=$OPTARG
      echo threads $th
      ;;
    ?)
      echo "unknown arguments" 
      usage 
      exit 1 ;;
  esac
done
echo '$inf $oud $th' $inf $oud $th
echo 


main
echo 
del_tmp 
