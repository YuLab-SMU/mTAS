#!/bin/bash

refd="/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/database/ICEberg"
cd $refd


dirs=`ls -l "$refd"/ | grep "^d" | awk -F' ' '{print $NF}' `
echo "$dirs"
echo 

for dir in `echo "$dirs" `;do 
  echo dir $dir 
  
  oud=$refd/$dir/sim_hder
  mkdir -p $oud 
  echo oud $oud 

  inf=$refd/$dir/"$dir"_seq_all.fas
  [ $dir == T4SS ] && inf=$refd/$dir/"$dir"-type_ICE_seq_all.fas 
  echo inf `ls $inf `
  fn=${inf##*/}
   
  map=$oud/encode.map 
  echo map `ls $map`
  ouf=$oud/$fn
  echo ouf `ls $ouf`
   
  python3 -m fasta_encoder -m encode -i $inf -o $ouf -F 1 -e $map 
  echo output written to $ouf 
  echo 
  
done 

