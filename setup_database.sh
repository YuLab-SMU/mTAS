#!/bin/bash
set -e 

# Descirption:
#   check, download and setup some of the database files 

wd=$1 
[ ${#@} -eq 0 ] && wd=database
mkdir -p $wd 

# Pfam 
version="current_release"
root="http://ftp.ebi.ac.uk/pub/databases/Pfam"
hmm="$root/$version/Pfam-A.hmm.gz"
md5="$root/$version/md5_checksums"
p=`pwd`

mkdir -p $wd/Pfam


# md5sum file
[ ! -f $wd/Pfam/md5_checksums ] && wget -c $md5 -O $wd/Pfam/md5_checksums 
sed -n  "/Pfam-A.hmm.gz/p" $wd/Pfam/md5_checksums > $wd/Pfam/md5.tmp

# hmm.gz
if [ ! -f $wd/Pfam/Pfam-A.hmm ] ;then 
    #wget -c $hmm -O $wd/Pfam/Pfam-A.hmm.gz 
    gzip -k -d $wd/Pfam/Pfam-A.hmm.gz # no need to depress, viralVerify accepts gz file 
    cd $wd/Pfam 
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

 

# pull database from gh-page branch 
link=https://github.com/YuLab-SMU/mTAS.git 
git clone -b gh-pages $link $wd/mTAS-db
mv $wd/mTAS-db/database/* $wd 
rm -r $wd/mTAS-db 

# unzip database 
cd $wd 
md5sum -c <<< `cat -v md5sum | sed "s/\^M//"` >$p/log 2>&1

check=`cut -f2 -d' ' $p/log | sort | uniq`
if [ $check != 'OK' ];then
    echo ERROR: database file is not complete, you may try re-downloading
    echo "`grep -v 'OK' $p/log `" | sed 's/^/  /g'
    exit
else  
    [ ! -d Rfam ] && tar -xf Rfam.tar.gz
    [ ! -d T1TAdb ] && tar -xf T1TAdb.tar.gz
    [ ! -d TADB2 ] && tar -xf TADB2.tar.gz
    [ ! -d TASmania_HMMs ] && tar -xf TASmania_HMMs.tar
    [ ! -d ICEberg/T4SS ]  && cd ICEberg && tar -xf T4SS.tar.gz && tar -xf ICE.tar.gz && tar -xf AICE.tar.gz && tar -xf IME.tar.gz && tar -xf CIME.tar.gz
fi


DB_ICEberg=$p/$wd/ICEberg
DB_Rfam=$p/$wd/Rfam
DB_T1TAdb=$p/$wd/T1TAdb
DB_TADB2=$p/$wd/TADB2
DB_TASmania=$p/$wd/TASmania

