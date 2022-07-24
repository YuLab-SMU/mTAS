#!/bin/bash
set -e 

que=$1
refd=$2
oud=$3
ths=$4
force='false'

[ ${#que} -eq 0 ] || [ ${#refd} -eq 0 ] && echo ERROR: must provide input/output folder && exit 
[ ${#ths} -eq 0 ] && ths=`nproc`
[ ${#oud} -eq 0 ] && oud=batch_iden_MGE_oud
[ $force == 'true' ] && rm -f -r $oud && mkdir -p $oud 

# qud=/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/spades_oud; refd=/share/Databases/ICEberg/fas


refs=`ls $refd/*/*_seq_all.fas`
ls $refd
 


function run_blastn() {
  # USAGE: bash hs-blastn.sh query.fa database output.fmt6
  query=$1
  subject=$2
  OUD=$3
  
  fn_que=${query##*/}
  bn_que=${fn_que%%.*}
  fn_sub=${subject##*/}
  bn_sub=${fn_sub%%.*}
   
  mkdir -p $OUD

  output=$OUD/$bn_que-$bn_sub.fmt6
  echo '  'aligning to subject $bn_sub
  #echo "    "`grep '>' $query`
  [ ! -f $OUD/$bn_sub.nto ] && makeblastdb -in $subject -out $OUD/$bn_sub -dbtype nucl
  
  if [ ! -f $output ] ;then  
    blastn -query $query -db $OUD/$bn_sub -out $output \
      -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle qacc qseqid' \
      -num_threads "$ths" \
      -word_size 21
	# -max_target_seqs 10 # 对于大序列query，设置本参数将减少匹配的TA
  else
      echo '    skip finished run'

  fi 

  mkdir -p $OUD
  echo 

  echo '[add_bn] '
  add_bn $output $OUD/$bn_sub.fmt6
  echo 
  echo '[call best hit]'
  call_besthit $OUD/$bn_sub.fmt6 $OUD
}


function call_besthit {
    fmt6=$1
    oud2=$2
    
    fn_fmt6=${fmt6##*/}
    bn_fmt6=${fn_fmt6%.*}
    #echo "$i / $count" $fn_fmt6
    
    ouf2=$oud2/$bn_fmt6.PI.fmt6
    ouf1=$oud2/$bn_fmt6.PI.tbl
    
    python3 utils/best_hit_calling.py -i $fmt6 \
	-o $ouf1 -O $ouf2 \
	-s $'\t' -S $'\t'

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


# blast
for ref in `ls $refd/*/sim_hder/*_seq_all.fas `;do
    # for ref in `ls $refd/*.fas `;do
    ls $ref
    
    fn_ref=${ref##*/}
    echo $fn_ref
    bn_ref=`basename $fn_ref .fas`
    typ=`echo $bn_ref | cut -f1 -d'-'` 
    echo bn_ref $bn_ref
    echo typ $typ 
    echo qud $qud
    echo que $que
    echo oud $oud 
     
    run_blastn $que $ref $oud/$bn_ref # 单个genome/contig文件
    echo
      
done 

exit


# add hder to indivdual fmt6 file 
hder='#bn_query,query,subject,identity,alignment length,mismatches,gap openings,q. start,q. end,s. start,s. end,e-value,bit score,query size,subject size,subject description,qacc,qseqid'
hder=`echo "$hder" | tr ',' $'\t'`

for ref in `ls $refd/*/*_seq_all.fas`; do
    fn_ref=${ref##*/}
    bn_ref=`basename $fn_ref .fas`

    oud2=$oud/$bn_ref/PI/temp_dir
    rm -f -r $oud/$bn_ref/PI 
    mkdir -p $oud2
    for fmt6 in `ls $oud/$bn_ref/*.fmt6 | sed '/fmt6-not-empty.sum.fmt6/d' `; do
      echo adding hder to [$bn_ref] $fmt6
      fn_fmt6=${fmt6##*/}
      bn_fmt6=${fn_fmt6%.*}
      #echo bn_fmt6 $bn_fmt6       
      echo "$hder" > $oud2/$fn_fmt6
      sed "s/^/$bn_fmt6\t/g" $fmt6 >> $oud2/$fn_fmt6
      count1=`wc -l $fmt6 | cut -f1 -d' '`
      count2=`wc -l $oud2/$fn_fmt6 | cut -f1 -d' '` 
    done 
  done 

echo written output to $oud/*/PI/temp_dir
  
 



