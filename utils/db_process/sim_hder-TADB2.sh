#!/bin/bash
set -e 

# simplify the long header of TADB2 
wd=/share/Users/Zehan/Packages/mTAS/mTAS-dev0.3/database/TADB2
cd $wd  

### nucleotide sequences 

Tref=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/merge.fna
ATref=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/antitoxin/merge.fna

Touf=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/merge2.fna
ATouf=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/antitoxin/merge2.fna

Tmap=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/encode.map
ATmap=/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/antitoxin/encode.map 

#ls $Tref 
#ls $ATref 

# encoder fasta, by the first word 
python3 -m fasta_encoder -m encode \
    -i $ATref -e $ATmap -F 1 -o $ATouf 
python3 -m fasta_encoder -m encode \
    -i $Tref -e $Tmap -F 1 -o $Touf 

#echo 
#echo ATouf $ATouf
#echo Touf $Touf
echo Tmap $Tmap 
echo ATmap $ATmap 
#echo
#echo

 

### amino acid sequences 

Tind=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/toxin
ATind=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/antitoxin

Tref=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/toxin/merge.fna
ATref=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/antitoxin/merge.fna

Touf=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/toxin/merge2.fna
ATouf=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/antitoxin/merge2.fna

Tmap=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/toxin/encode.map
ATmap=/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/antitoxin/encode.map

rm -f $Tref
for F in `ls $Tind | grep -v "merge"`; do
    #echo F $F 
    #ls $Tind/$F
    cat $Tind/$F >> $Tref
done
echo Tref `ls $Tref`
 

rm -f $ATref
for F in `ls $ATind | grep -v "merge"`; do
    #echo 
    #ls $ATind/$F
    cat $ATind/$F >> $ATref
done
#echo ATref `ls $ATref`
echo
 


python3 -m fasta_encoder -m encode \
    -i $ATref -e $ATmap -F 1 -o $ATouf
python3 -m fasta_encoder -m encode \
    -i $Tref -e $Tmap -F 1 -o $Touf

sed -i '1d' $ATmap 
sed -i '1d' $Tmap

#echo ATouf `ls $ATouf`
#echo Touf `ls $Touf`
echo ATmap `ls $ATmap`
echo Tmap `ls $Tmap`


python3 add_label.py 
