#!/usr/bin/python3

# Description: call best-hit subject for each query based on PI
#  for every query-subject match, either global/local alignment, PI = sequence coverage % * identity %


import sys, getopt
import pandas as pd
import numpy as np
from pandas import Series, DataFrame

"""
python3 $scp2 $sizefmt6 \
    $oud/$bn_ref/PI/fmt6-not-empty.sum.maxPI.tbl \
    $oud/$bn_ref/PI/fmt6-not-empty.sum.maxPI.fmt6 \
    $'\t' \
    $'\t'
"""

opts, args = getopt.getopt(sys.argv[1:],
        '-i:-o:-O:-s:-S:-h',['--infile', '--out_tbl', '--out_tbl2', 
            '--insep', '--outsep2', '--help'])

#print('opts',opts)
#print('args',args)
for opt_name,opt_value in opts:
    if opt_name in ('-i'):
        inf=opt_value
        #print('input file =',inf)

    elif opt_name in ('-o'):
        ouf=opt_value
        #print('outfile table =',ouf)
    elif opt_name in ('-O'):
        ouf2=opt_value
        #print('outfile fmt6 =',ouf2)
    elif opt_name in ('-s'):
        insep=opt_value
        #print("input delitmmer",insep)
    elif opt_name in ('-S'):
        outsep=opt_value
        #print("output delitmmer",outsep)
    elif opt_name in ('-h','--help'):
        print(' '.join([
            'python3 blast-best_hit_calling2.py \\\n',
            '-i $input_file\\\n',
            '-o $out_file_tsv\\\n',
            '-O $out_file_fmt6\\\n',
            '-s $in_sep\\\n',
            '-S $out_sep\\\n'
            ]))
        

label = 'bn' # or 'original'

####################

def max_df(df1,df2):
  """
  accept two objects in the same height, to find the bigger ones on the same indexes 
  data pandas.core.series
  returns a list containing maximum values and the index of the original dataframe fram
  """
  if ( len(df1) != len(df2) ):
    print('[max_df(df1,df2)] ERROR: input dataframes are not of the same size')
    exit()
  
  maxPI_lst = []
  
  for idx in df1.index:
    PI1 = float(df1.loc[[idx]])
    PI2 = float(df2.loc[[idx]])
    maxPI_lst.append( [ idx, max(PI1,PI2) ] )  
  return maxPI_lst 


def get_max_item(lst):
  """
  input a nested list:[ [idex1,item2] ..[idexN,itemN] ]
  return the maximum and its index 
  """
  olst = ['']
  max=0
  for sublst in lst:
    if (sublst[1] > max): 
      olst[0] = sublst # olst only stores one var, current list
      max = sublst[1]

  # check:  
  #  if the same maximum valules with different index 
  olst2 = []
  max_item = olst[0][1]
  for sublst in lst:
    if (sublst[1] == max_item):
      olst2.append(sublst)

  return olst2


def merge_region(region_lst):
  olst = []
  region_lst = sorted(region_lst)  
  for idx in range(0,len(region_lst)):
    if ( idx == 0):
      olst.append( [  min( region_lst[idx][0],region_lst[idx][1] ),
                      max( region_lst[idx][0],region_lst[idx][1] ) ] )
    else: 
      qsta = min(region_lst[idx][0],region_lst[idx][1])
      qend = max(region_lst[idx][0],region_lst[idx][1])

      qsta0 = olst[len(olst)-1][0]
      qend0 = olst[len(olst)-1][1]

      if int(qsta) <= int(qend0):
        qsta = min(qsta,qend,qsta0,qend0)
        qend = max(qsta,qend,qsta0,qend0)
        olst[len(olst)-1] = [qsta,qend]
      elif int(qsta) > int(qend0):
        olst.append([qsta,qend])
      else:  
        print('ERROR')
        exit()
  return olst


def sumup_lst(inlst):
  sum = 0
  for item in inlst:
    sum = sum + abs(item[1] - item[0]) + 1
  return sum


def get_max_min(inlst):
  clst1 = [ item[0] for item in inlst ]
  clst2 = [ item[1] for item in inlst ] 
  clst3 = [ clst1[0],clst1[len(clst1)-1], clst2[0],clst2[len(clst2)-1] ]
  clst3.sort()
  return clst3[0],clst3[len(clst3)-1]


def get_mergePI(df):
  """
  inputs a df, merge PI，returns list
  those of both query and subject will be calculated and check the maximum 
  """
  qreg_lst = []
  sreg_lst = []  

  que_size = df.loc[list(df.index)[0],'qlen']
  sbj_size = df.loc[list(df.index)[0],'slen']
  
  iden = list(df['pident'])

  mean_iden = np.mean(iden) # takes means for all identities in this version 
  
  for idx in df.index:
    qsta = int(df.loc[idx,'qstart'])
    qend = int(df.loc[idx,'qend'])
    ssta = int(df.loc[idx,'sstart'])
    send = int(df.loc[idx,'send'])
    qreg_lst.append([qsta,qend])
    sreg_lst.append([ssta,send])  

  qlst = merge_region(qreg_lst) # merge regions, returns non-overlap region llist, nested list
  slst = merge_region(sreg_lst)
   
  que_hitlen = sumup_lst(qlst) # calculate merge region length
  sbj_hitlen = sumup_lst(slst)
 
  qPIreg1,qPIreg2 = get_max_min(qlst)
  sPIreg1,sPIreg2 = get_max_min(slst)

  qlst = [ [str(sublst[0]), str(sublst[1]) ] for sublst in qlst ]
  qlst = [ '-'.join(sublst) for sublst in qlst ]

  qlst = ';'.join(qlst)

  slst = [ [str(sublst[0]), str(sublst[1]) ] for sublst in slst ]
  slst = [ '-'.join(sublst) for sublst in slst ]

  qPI = que_hitlen / que_size * mean_iden / 100 
  sPI = sbj_hitlen / sbj_size * mean_iden / 100 
  return qPI,sPI,qPIreg1,qPIreg2,qlst,slst 


def get_hiPI(hit_rows):
  # threshold PI>0.81
  # accepts a df, return hi-scoring df and the complements 
  #     high score PI indicates the query is highly similar to the subject 
  #     but not vice versa, there could be multiple local hits which can be combined to go high

  olst = []
 
  cols = list(hit_rows.columns)
  cols.append('PI')
  cols.append('label')

  bn = list(hit_rows['#bn_query'])[0]
  sbj = list(hit_rows['saccver'])[0]
  que = list(hit_rows['qaccver'])[0]

  PI_rows = pd.DataFrame(columns=cols)
  
  qPI = hit_rows.apply( lambda x: x['pident']/100 * float(x['length'])/float(x['qlen']), axis = 1) 
  sPI = hit_rows.apply( lambda x: x['pident']/100 * float(x['length'])/float(x['slen']), axis = 1) 
  
  maxPI_lst = max_df(qPI,sPI)
  maxPI_lst = get_max_item(maxPI_lst) # all items with max PI and their corresponding indexes
      
  for sublst in maxPI_lst:
    maxPI_idx = sublst[0]
    maxPI = sublst[1]
    maxPI_row = hit_rows.loc[[maxPI_idx]].copy() # the row/rows with the max PI 
    # iloc[[]] subsets by the actual row number but not by index 
    maxPI_row.loc[:,'PI'] = maxPI # add PI to a new column 
    
    if ( maxPI >= 0.85 ):
      maxPI_row.loc[:,'label'] = 'known'
      reg1 = str( maxPI_row['qstart'].tolist()[0])
      reg2 = str(maxPI_row['qend'].tolist()[0]) 
      reg_str = '-'.join([reg1,reg2]) 
      PI_rows = pd.concat([PI_rows,maxPI_row],axis=0)   
      olst.append( [bn,que,sbj,reg1,reg2,reg_str,maxPI,'known'] ) 
    
  # if no hi PI were found after this step, conduct the next check step 
  # check length of the hiPI_rows to confirm if hi PI exists
  # if so, give up the results calculated before, combine all rows hit_rows to calculate 
   
    if ( len(olst)==0 ):
      merge_qPI,merge_sPI,reg1,reg2,reglst1,reglst2 = get_mergePI(hit_rows)
      maxPI = max(merge_qPI,merge_sPI)

      if (maxPI >= 0.85):
        olst.append( [bn, que, sbj, reg1, reg2, reglst1, maxPI, 'known'] )
        orows = hit_rows.copy()
        orows.loc[:,'PI'] = maxPI 
        orows.loc[:,'label'] = 'known'
        PI_rows = pd.concat([PI_rows,orows],axis=0)
      elif (maxPI < 0.85) and (maxPI >= 0.25): 
        olst.append( [bn,  que, sbj, reg1, reg2, reglst1, maxPI, 'divergent'])
        orows = hit_rows.copy()  
        orows.loc[:,'PI'] = maxPI
        orows.loc[:,'label'] = 'divergent'
        PI_rows = pd.concat([PI_rows,orows],axis=0)
      #else: #  
      #  olst.append( [bn,que,sbj,maxPI,'lowPI'])
      #  orows = hit_rows.copy()
      #  orows.loc[:,'PI'] = maxPI
      #  orows.loc[:,'label'] = 'lowPI'
      #  PI_rows = pd.concat([PI_rows,orows],axis=0)
      #only has a subject, ignore other subject
      #in extern, check whether hiPI_rows is empty to figure out if query matches subject
 
  return olst,PI_rows # bn query subject PI


def main_bn(df):
  # main run base name mode 
  cols = list(df.columns)
  cols.append('PI') 
  cols.append('label')
  
  results_df = pd.DataFrame(columns=cols) 
  results = []
  bn_lst = pd.unique(df['#bn_query'])
  
  count_bn = len(bn_lst) 

  i = 0  
  for bn in bn_lst:
    i += 1 
    print('  [main_bn] '+ str(i) + ' /' + str(count_bn) )
    bn_que_hits = df[ df['#bn_query']==bn ] # all rows of the same basename 
    #print('1',bn_que_hits)
    #print(bn_que_hits.columns)
    
    que_lst = pd.unique(bn_que_hits['qaccver']).tolist()  # unique query list
    for que in que_lst:
      que_rows = df[ df['qaccver']==que ]
      sbj_lst = que_rows['saccver'] # must not deduplicate 
      for sbj in sbj_lst:
        hit_rows = que_rows[ (que_rows['qaccver']==que) & (que_rows['saccver']==sbj) ]
        hits_with_PI_lst,hits_with_PI_df = get_hiPI(hit_rows)  # PI >= 0.81
        results.append(hits_with_PI_lst)
        results_df = pd.concat([results_df, hits_with_PI_df],axis=0)

  # write output
  with open(ouf,'w') as out:
    hder = outsep.join([ '#bn_query','qaccver','saccver','qstart','qend','qregions','maxPI','label\n' ])
    out.writelines(hder)
  with open(ouf,'a') as out:
    for item in results:
      for item2 in item:
        item2 = [ str(i) for i in item2 ]
        out.writelines(outsep.join(item2)+'\n')
  results_df.to_csv(path_or_buf=ouf2, index=False, sep=outsep) 
  print('  output written to',ouf, ouf2) 

####################

# IO 
df = pd.read_csv(inf,sep=insep) 
cols = list(df.columns) 
cols = cols.append('PI')  
out_df = pd.DataFrame(columns=cols)
main_bn(df)


