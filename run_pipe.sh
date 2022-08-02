#!/bin/bash
set -e 

ind_reads=$1
final_oud=$2

[ ${#ind_reads} -eq 0 ] && echo ERROR: please provide input path && exit  
[ ! -d $ind_reads ] && echo ERROR: please provide input path && exit 
[ ${#final_oud} -eq 0 ] && final_oud="output/final_oud"

# set up 
echo "ind_reads: $ind_reads" > config/IO.yaml
echo "final_oud: $final_oud" >> config/IO.yaml

# pull database files
database="database"
bash setup_database.sh $database 

# run pipeline 
snakemake -p -s snakefile -c all



