#!/bin/bash
set -e 

# Descirption:
#   check, download and setup some of the database files 

link1=https://github.com/YuLab-SMU/mTAS.git
link2=https://gitee.com/wolfgang1989/mTAS.git
wd=$1 

[ ${#@} -eq 0 ] && wd=database
mkdir -p `pwd`/$wd 
p=`pwd`
pfamd=$p/$wd/Pfam

# pull curated database from gh-page branch  
if [ ! -f $wd/CDTAS/database/md5sum ]; then 
  bash $p/utils/ping_git_src.sh # ping and compare delays  
  src=`cat label.tmp` 
   
  if [ "$src" == 'gitee' ]; then
      link=$link2 # select url based on delay
  else
      link=$link1 
  fi 
  git clone -b gh-pages $link $wd/CDTAS
fi

#t unzip database 
cd $wd/CDTAS/database 
md5sum -c <<< `cat -v md5sum | sed "s/\^M//"` >$p/log 2>&1
 
check=`cut -f2 -d' ' $p/log | sort | uniq`
 
if [ $check != 'OK' ];then
    echo ERROR: database file is not complete, you may try re-downloading
    echo "`grep -v 'OK' $p/log `" | sed 's/^/  /g'
else
    [ ! -d Rfam ] && tar -xf Rfam.tar.gz
    [ ! -d T1TAdb ] && tar -xf T1TAdb.tar.gz
    [ ! -d TADB2 ] && tar -xf TADB2.tar.gz
    [ ! -d TASmania_HMMs ] && tar -xf TASmania_HMMs.tar
    [ ! -d ICEberg/T4SS ]  && cd ICEberg && tar -xf T4SS.tar.gz && tar -xf ICE.tar.gz && tar -xf AICE.tar.gz && tar -xf IME.tar.gz && tar -xf CIME.tar.gz
fi
 


# download Pfam
version="current_release"
root="http://ftp.ebi.ac.uk/pub/databases/Pfam"
hmm="$root/$version/Pfam-A.hmm.gz"
md5="$root/$version/md5_checksums"

mkdir -p $pfamd

# md5sum file 
#ouf_md5=$p/$wd/Pfam/md5_checksums 
ouf_md5=$pfamd/md5_checksums 
[ ! -f $ouf_md5 ] && wget -c $md5 -O $ouf_md5
 
sed -n "/Pfam-A.hmm.gz/p" $ouf_md5 > $pfamd/md5.tmp
  
if [ ! -f $pfamd/Pfam-A.hmm ] ; then
    wget -c $hmm -O $pfamd/Pfam-A.hmm.gz
    gzip -k -d $pfamd/Pfam-A.hmm.gz # no need to depress, viralVerify accepts gz file
    cd $pfamd
    md5sum -c md5.tmp | tee $p/log
    check=`cut -f2 -d' ' $p/log`
    if [ $check != 'OK' ];then
	echo ERROR: Pfam.hmm file is not complete
	exit
    else
	echo downloaded Pfam-A.hmm.gz is complete
    fi
    cd $p
fi

rm -f $p/label.tmp $p/log 
