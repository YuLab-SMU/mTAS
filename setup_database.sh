#!/bin/bash
set -e 

# Descirption:
#   check, download and setup some of the database files 

wd=$1
[ ${#@} -eq 0 ] && echo ERROR: must provide output path && exit 
mkdir -p $wd 
 
# TADB2
# unzip

# 

# Pfam 
version="current_release"
root="http://ftp.ebi.ac.uk/pub/databases/Pfam"
hmm="$root/$version/Pfam-A.hmm.gz"
md5="$root/$version/md5_checksums"
 
p=`pwd`


if [ ! -f $wd/Pfam/$Pfam-A.hmm ]; then
  mkdir -p $wd/Pfam
  [ ! -f $wd/Pfam/Pfam-A.hmm.gz ] && wget -c $hmm -O $wd/Pfam/Pfam-A.hmm.gz # no need to depress, viralVerify accepts gz file    
  [ ! -f $wd/Pfam/md5_checksums ] && wget -c $md5 -O $wd/Pfam/md5_checksums 
   
  cd $wd/Pfam 
    
  md5sum -c md5_checksums | tee $p/log  
  check=`cut -f2 -d' ' $p/log`
  if [ $check != 'OK' ];then 
    echo ERROR: Pfam.hmm file is not complete 
    exit 
  fi

  cd $p 
  gzip -d $wd/Pfam/Pfam-A.hmm.gz      
fi
 


# database
link=https://gitee.com/wolfgang1989/cdtasc.git 
 
cd $p
[ ! -d cdtasc ] && git clone $link

cd cdtasc
# TASmania_HMMs.tar  TADB2.tar.gz  LICENSE  README.en.md  Rfam.tar.gz  T1TAdb.tar.gz  ICEberg
md5sum -c md5sum > $p/log 
check=`cut -f2 -d' ' $p/log | sort | uniq`
if [ $check != 'OK' ];then
    echo ERROR: database file is not complete, you may try re-downloading
    exit
fi

[ ! -d Rfam ] && echo 2 && tar -xf Rfam.tar.gz
[ ! -d T1TAdb ] && echo 3 && tar -xf T1TAdb.tar.gz
[ ! -d TADB2 ] && echo 4 && tar -xf TADB2.tar.gz
[ ! -d TASmania_HMMs ] && echo 5 && tar -xf TASmania_HMMs.tar
[ ! -d ICEberg/T4SS ]  && echo 1 && cd ICEberg && tar -xf T4SS.tar.gz && tar -xf ICE.tar.gz && tar -xf AICE.tar.gz && tar -xf IME.tar.gz && tar -xf CIME.tar.gz

# Refseq virus/plasmid 
# deprected since this the plasmid is too large (over 1G) and the ftp volumns are flexible. 



