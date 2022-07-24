#!/bin/bash
set -e 

que=$1
refd=$2
oud=$3 
ths=$4

[ ${#que} -eq 0 ] || [ ${#refd} -eq 0 ] && echo ERROR: must provide input/output folder && exit

[ ${#ths} -eq 0 ] && ths=`nproc`
[ ${#oud} -eq 0 ] && oud=batch_iden_MGE_oud

#qud=/share/Databases/NCBI/Genome/Pseudomonsa_aeruginosa/download_dir_PAgenome_allLv
#oud=oud_01-1PAchr-blastn-TADB2ATsubset
#refd=/share/Databases/ICEberg/fas
#dep=best_hit_calling.py

# que=/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/spades_oud/SRR10763342.fa ; refd=/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/database/ICEberg ; oud=test_oud_batch_iden_MGE ; ths=72 ; bash  

function run_blastn() {
  # USAGE: bash hs-blastn.sh query.fa database output.fmt6
  query=$1
  subject=$2
  OUD=$3
  
  fn_que=${query##*/}
  bn_que=${fn_que%%.*}
  fn_sub=${subject##*/}
  bn_sub=${fn_sub%%.*}
  
  output=$OUD/$bn_que-$bn_sub.fmt6
  echo '  'aligning to subject $bn_sub
  #echo "    "`grep '>' $query`
  [ ! -f $OUD/$bn_sub.nto ] && makeblastdb -in $subject -out $OUD/$bn_sub -dbtype nucl
  
  blastn -query $query -db $OUD/$bn_sub -out $output \
      -outfmt '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle qacc qseqid' \
      -num_threads $ths \
      -word_size 21
	# -max_target_seqs 10 # 对于大序列query，设置本参数将减少匹配的TA
}


function add_bn {
    # 在fmt6输出前每行加上文件名
    blastn_dir=$1 # $oud/hs-blastn-out
    ls $blastn_dir/*.fmt6 -l  | awk -F' ' '$5!=0{print $NF}' > $blastn_dir/fmt6-not-empty.lst
    
    rm -f $blastn_dir/fmt6-not-empty.sum.fmt6
    while read fmt6 ; do
	fn=${fmt6##*/}
	bn=${fn%%.*}
	sed "s/^/$bn\t/" $fmt6  >>  $blastn_dir/fmt6-not-empty.sum.fmt6
    done < $blastn_dir/fmt6-not-empty.lst
    hder='#bn_query,query,subject,identity,alignment length,mismatches,gap openings,q. start,q. end,s. start,s. end,e-value,bit score,query size,subject size,subject description,qacc,qseqid'
    hder=`echo "$hder" | tr ',' $'\t'`
    sed -i "1i $hder"  $blastn_dir/fmt6-not-empty.sum.fmt6
}


main() {
    REF=$1
    QUE=$2
    OUD=$3
    
    mkdir -p $OUD
    
    echo REF $REF
    echo QUE $QUE
    echo OUD $OUD
   	
    run_blastn $QUE $REF $OUD
    add_bn $OUD
}		


# blast 

 
for ref in `ls $refd/*/*_seq_all.fas `;do
    # for ref in `ls $refd/*.fas `;do
    ls $ref
    
    fn_ref=${ref##*/}
    bn_ref=`basename $fn_ref .fas`
    typ=`echo $bn_ref | cut -f1 -d'-'` 
    echo bn_ref $bn_ref
    echo typ $typ 
    echo que $que
    
    main $ref $que $oud/$bn_ref # 单个genome/contig文件
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
      #count1=`expr $count1 + 1`
      #if [ $count2 > $count1 ];then 
      #  echo "count2 > count1:"
#      wc -l $oud2/$fn_fmt6
#wc -l $fmt6 ##	  exit 
#fi
      #head $oud2/$fn_fmt6 
    done 
done 
echo written output to $oud/*/PI/temp_dir
echo
echo
 


# create cmd list  
echo create cmd list 
for ref in `ls $refd/*/*_seq_all.fas`; do
    fn_ref=${ref##*/}
    bn_ref=`basename $fn_ref .fas`
    #typ=`echo $bn_ref | cut -f1 -d'-'`

    oud2=$oud/$bn_ref/PI/temp_dir
    rm -f $oud/$bn_ref/PI/temp_dir/cmd.lst.tmp
    i=0
    count=`ls $oud2/*.fmt6 | wc -l`
    echo count $count 
    echo oud2 $oud2 
    rm -f $oud2/*.PI.*
     
    for OUF in `ls $oud2/*.fmt6 | sed '/fmt6-not-empty.sum.fmt6/d' `; do
	i=`expr $i + 1`
        fn_fmt6=${OUF##*/}
	bn_fmt6=${fn_fmt6%.*}
	echo "$i / $count" $fn_fmt6

	ouf2=$oud2/$bn_fmt6.PI.fmt6
        ouf1=$oud2/$bn_fmt6.PI.tbl

        echo "python3 $scp2 -i $OUF -o $ouf1 -O $ouf2 -s $'\t' -S $'\t'" >> $oud/$bn_ref/PI/temp_dir/cmd.lst.tmp
    done 
    echo written cmd list to $oud/$bn_ref/PI/temp_dir/cmd.lst.tmp
done
echo "finished"
echo "path to cmd list"
ls $oud/*/PI/temp_dir/cmd.lst.tmp 
echo 



# best hit calling 2
echo parallel run 
rm -f $oud/stepdone_parallel_run 
#touch $oud/stepdone_parallel_run 
if [ ! -f $oud/stepdone_parallel_run ];then 
# parallel run 
  for cmdfile in `ls $oud/*/PI/temp_dir/cmd.lst.tmp`; do
    #[]grep GCA_905071885 $cmdfile > tmp1 
    echo cmdfile $cmdfile 
    #[]parallel --jobs 70 < tmp1 
    parallel --jobs 70 < $cmdfile

  done
fi 
touch $oud/stepdone_parallel_run
echo 


exit 

[legacy]
for ref in `ls $refd/*/*_seq_all.fas`; do
    fn_ref=${ref##*/}
    bn_ref=`basename $fn_ref .fas`

    rm -f $ouf1 $ouf2 
    ouf1=$oud/$bn_ref/PI/fmt6-not-empty.sum.maxPI.tbl
    #ouf2=$oud/$bn_ref/PI/fmt6-not-empty.sum.maxPI.fmt6
  
    #ls $oud/$bn_ref/PI/temp_dir/*.fmt6 | wc -l 
    ls $oud/$bn_ref/PI/temp_dir/*.tbl | wc -l 
     
    #top1file=`ls $oud/$bn_ref/PI/temp_dir/*.fmt6 | head -n 1`
    top2file=`ls $oud/$bn_ref/PI/temp_dir/*.tbl | head -n 1`
    #hder1=`head -n 1 $top1file`
    hder2=`head -n 1 $top2file`
     
    oud2=$oud/$bn_ref/PI/temp_dir
    #for fmt6 in `ls $oud2/*.fmt6 | sed '/fmt6-not-empty.sum.fmt6/d'  `; do
    #    cat $fmt6 >> $ouf1 
    #    echo '  '$fmt6 
    #done
    #sed -i "1i $hder1" $ouf1  
    for tbl in `ls $oud2/*.tbl `; do
	cat $tbl >> $ouf2
	echo '  '$tbl 
    done
    sed -i "1i $hder2" $ouf2 

    echo add Pi to fmt6, output file:$'\n' $ouf1$'\n' $ouf2
    echo
    
done

# parallel best hit calling  


# 

