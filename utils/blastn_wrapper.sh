#!/bin/bash

set -e 

# Description: blastn wrapper for single fasta input 

# Update: 2022-06-15
#     align against a batch of database files 


usage() {
    echo Usage: $0 "[ -i INPUT/FASTA ] [ -I INPUT/FOLDER ] [ -r REFERENCE/FILE ] [ -R REFERENCE/FOLDER ] [ -o PATH/TO/OUTPUT_FILE ] [ -O OUTPUT/FOLDER ] [ -h ] "
    echo "  Example1: bash blastn_wrapper.sh -i spades_oud/SRR10763342.fa -r database/TADB_typeII_antitoxin.fa -o 05-1blastn_AT/SRR10763342.fmt6 -O 05-1blastn_AT "
}

#que=/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/spades_oud/SRR10763342.fa ; ref=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/merge2.fna ; oud=test_blastn_oud ; bash blastn_wrapper.sh -i $que -r $ref -O $oud


[ ${#@} -eq 0 ] && echo ERROR: No arguments provided$'\n' && usage && exit


while getopts "i:r:R:o:O:h" arg ; do
    case $arg in
    i)
        #echo infile $OPTARG
        inf=$OPTARG
	;;
#    I) 
	#echo input directory $OPTARG
#	ind=$OPTARG # not supported for input directory 
#	;;
    o)
	#echo outfile $OPTARG
	ouf=$OPTARG
        ;;
    O)
	#echo outfoler $OPTARG
	oud=$OPTARG
	;;
    R)  
	#echo $OPTARG
	refd=$OPTARG 
	if [ -d $refd ] ;then
	    label="folder"
	else
	    echo Type error $refd
	fi
	;;
    r) 
	ref=$OPTARG
        if [ -f $ref ] ; then 
	    label="file"
	else
            echo Type error $ref 
	fi 
	echo reffile $ref
	;;
    t)
	ths=$OPTARG
	;;
    h) # claim the input are paired
        usage
	echo 	
	;;
    ?)
        echo "unknown arguments"
	echo 
  	usage
	exit 1
       	;;
    esac
done

### argument check
if [ ${#refd} -ne 0 ] && [ ${#ref} -ne 0 ];then
   echo ERROR: variable conflict {refd} and {ref} 
   echo   refd "${refd}"
   echo   ref "${ref}"
   echo 
   echo   only A single ref file or A directory containing ref file is accepted
   exit 
fi # pass test 

[ ${#ths} -eq 0 ] && ths=`nproc`

function run_blastn() {
    # USAGE: bash blastn.sh query.fa database output.fmt6
    query=$1
    subject=$2
    OUD=$3
    
    fn_que=${query##*/}
    bn_que=${fn_que%%.*}
    fn_sub=${subject##*/}
    bn_sub=${fn_sub%%.*}
    
    [ ${#OUD} -eq 0 ] && OUD=`pwd`/blastn_oud
    mkdir -p $OUD/$bn_que
    #echo $OUD/$bn_que

    output=$OUD/$bn_que/$bn_que-$bn_sub.fmt6
    echo '  '[run blastn] aligning to subject $bn_sub
    #echo $output 
    #ls $OUD/$bn_sub.nto  
    [ ! -f $OUD/$bn_sub.nto ] && makeblastdb -in $subject -out $OUD/$bn_sub -dbtype nucl > /dev/null

    blastn -query $query -db $OUD/$bn_sub -out $output \
	-outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle qacc qseqid' \
	-num_threads 72 \
	-word_size 21
     
    mkdir -p $OUD/$bn_que/tmp_dir 

    add_bn $output $OUD/$bn_que/tmp_dir/$bn_sub.fmt6
    #ls $OUD/$bn_que/tmp_dir/$bn_sub.fmt6 
    # [legacy] -max_target_seqs 10 # keep only 10 hit references # for large genomes, this would negalect many hit reference, only 10 out of actual hundreds or thousands were kept
    
    call_besthit $OUD/$bn_que/tmp_dir/$bn_sub.fmt6 $OUD/$bn_que/tmp_dir
}   


function add_bn {
    # add basename of the input file as a new column
    echo '  '[add_bn] adding base name and headers to format 6 tables 
    fmt6=$1
    OUF=$2 # add_hder  

    fn=${fmt6##*/}
    bn=${fn%%.*}  

    sed "s/^/$bn\t/g" $fmt6 > $OUF 

    hder=`echo "#bn_query" qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle qacc qseqid | tr ' ' $'\t'`
    sed -i "1i $hder" $OUF
    echo '  [add_bn] written output to '"$OUF"
}

function call_besthit {
    fmt6=$1 
    oud2=$2 
    
    

    #i=`expr $i + 1`
    fn_fmt6=${fmt6##*/}
    bn_fmt6=${fn_fmt6%.*}
    #echo "$i / $count" $fn_fmt6
    
    ouf2=$oud2/$bn_fmt6.PI.fmt6
    ouf1=$oud2/$bn_fmt6.PI.tbl
    
    python3 utils/best_hit_calling.py -i $fmt6 \
	-o $ouf1 -O $ouf2 \
	-s $'\t' -S $'\t'
}

function main {
    echo inf $inf
    echo ref $ref / refd $refd 
    echo oud $oud     
    echo label $label  
    if [ $label == "file" ];then 
        run_blastn $inf $ref $oud 
    elif [ $label == "folder" ];then 
        for rf in `ls $refd/ | grep "fna\|fasta\|faa\|fas" `;do
	    echo ref $rf 	
	    run_blastn $inf $refd/$rf $oud 
	done 
    fi
}

main 




