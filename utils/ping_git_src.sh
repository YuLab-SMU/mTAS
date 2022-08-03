#!/bin/bash
set -e 


link=github.com #/YuLab-SMU/mTAS #mTAS.git
link2=gitee.com #/wolfgang1989/mTAS/tree/gh-pages
selec="github"


ping $link -c3 | tee ping_github.log 
ping $link2 -c3 | tee ping_gitee.log  
p1=`sed -n "/time=/p" ping_github.log`
p2=`sed -n "/time=/p" ping_gitee.log`
  
if [ ${#p1} -eq 0 ] && [ ${#p2} -ne 0 ] ; then
    selec="gitee"
fi

if [ ${#p1} -ne 0 ] && [ ${#p2} -ne 0 ] ; then 
    mean1=`echo "$p1" | awk -F' ' '{print $(NF-1)}' | awk -F'=' '{sum+=$2}END{print sum/NR}'`
    mean2=`echo "$p2" | awk -F' ' '{print $(NF-1)}' | awk -F'=' '{sum+=$2}END{print sum/NR}'`

    mean1=${mean1%.*}
    mean2=${mean2%.*}

    echo $mean1
    echo $mean2 

    [ $mean1 -le $mean2 ] && selec='github'
    [ $mean1 -gt $mean2 ] && selec='gitee'
fi
echo $selec > label.tmp 
rm ping_gitee.log  ping_github.log
