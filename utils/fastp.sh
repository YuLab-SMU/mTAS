#!/binb/bash
set -e 

# Description
#   input with raw fastq files, run fastp to filter reads with low quality, detect and filter adapters 
#   output with clearn data

# functions:
#   detect input files are/is single file/unpaired files/paired files
#   run with pair ended files or single files
#   main run

# Example1: pair ended fq files # test passed
#   bash scripts/01fastp.sh -i /mnt/e/sra_data/SRR11252610_1.fastq,/mnt/e/sra_data/SRR11252610_2.fastq -p -d test_out 

# Example2: single ended fq file # test passed
#   bash scripts/01fastp.sh -i /mnt/e/sra_data/SRR11252610.fastq -p -d test_out


usage() {
  echo Usage: $0 "[ -i INPUT.R1.fastq,INPUT.R2.fastq ] [ -d PATH/TO/OUTPUT_FOLDER ] \
          [ -p/-s ]"
  echo "  Example1: bash scripts/01fastp.sh -i SRR00001.R1.fastq,SRR00001.R2.fastq -o SRR00001.c1.fq,SRR00001.c2.fq -p # for pair ended fastq files "  
  echo "  Example1: bash scripts/01fastp.sh -i SRR00001.fastq -o SRR00001.c.fq -s # for single ended fastq file"$'\n'

}
[ ${#@} -eq 0 ] && echo ERROR: No arguments provided$'\n' && usage && exit


while getopts "i:d:ps" arg ; do 
  case $arg in 
    i)
      echo $OPTARG
      inf=$OPTARG 
      ;;
    #o)
      #echo $OPTARG
      #ouf=$OPTARG
      #;;
    d)
      oud=$OPTARG
      ;;
    p) # claim the input are paired 
      inf1=`echo "$inf" | cut -f1 -d','`
      inf2=`echo "$inf" | cut -f2 -d','`
      label='P'
      fn=${inf1##*/}
      bn=${fn%.*}
      echo $bn
      ;;
    s)
      label='S'
      fn=${inf##*/}
      bn=${fn%.*}
      echo $bn
      ;;
    ?)
      echo "unknown arguments" 
      usage 
      exit 1 ;;
  esac
done


run_pe() {
  b=$1
  echo '  'running paired ended data 
  fastp -h $oud/01QCreport/$b.fastp.html \
    -c -3 -W 4 --thread 12 \
    --in1 $inf1 \
    --in2 $inf2 \
    --out1 $oud/01clean_data/$b.R1.fq \
    --out2 $oud/01clean_data/$b.R2.fq --detect_adapter_for_pe
}

run_se() {
  b=$1
  echo '  'running single ended data $inf
  fastp -h $oud/01QCreport/$b.fastp.html \
    -c -3 -W 4 --thread 12 \
    --in1 $inf \
    --out1 $oud/01clean_data/"$b".1.c.fastq # --interleaved_in
}



main() {
  oud1=$oud/01clean_data
  oud2=$oud/01QCreport
  mkdir -p $oud1
  mkdir -p $oud2

  if [ "$label" == 'P' ]; then
    run_pe $bn 
  elif [ "$label" == 'S' ]; then
    run_se $bn 
  fi
}

main 

