#!/usr/bin/python3
 

# add TA type label, toxin/antitoxin label to encoder map
#    toxin antitoxin label根据id是否 AT T 就可以

import glob, os, sys
import pandas as pd

fna_TmapFile = '/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/encode.map'
fna_ATmapFile = '/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/antitoxin/encode.map'
 
fna_ATfiles = glob.glob('fna/antitoxin/*.fas')
fna_Tfiles = glob.glob('fna/toxin/*.fas')

##############

def map_tbl( map_file, fa_file, type_label, Component ):
    # read header from fasta files 
    # match the headers and the map files 
    
    with open(fa_file, 'r') as f:
        text = f.readlines()
    text = [ line for line in text if line.find('>') != -1 ] # get only headers

    df_map = pd.read_csv(map_file, sep = '\t', header=None)
    df_map.columns = ['original header', 'short header'] # original file has no headers

    odf = pd.DataFrame(columns = cols)
    type_label_list = []
    for hder in text:
        short = hder.split(' ')[0].replace('>', '')
        hit = df_map[ df_map['short header'] == short ].copy()
        hit['class'] = type_label 
        odf = odf.append(hit)

    odf['component'] = Component
    return odf

def main(fasta_files, MapFile, Component):
    global cols 
    cols = ['original header', 'short header', 'class', 'component']
    final_odf = pd.DataFrame(columns = cols ) #cols final output dataframe

    for File in fasta_files:
        compo = os.path.basename(File).split('.')[0] 
        Type = compo.split('_')[1]
        #print('compo',compo)
         
        #print(Type)
        odf = map_tbl( MapFile, File, Type, Component )
        final_odf = final_odf.append(odf)
        #print('\n','odf',odf,'\n')
    #print(final_odf)

    ouf = MapFile + '.2'
    final_odf.to_csv(ouf, index=None, sep='\t')
    print('output written to:', ouf)
##############


### main run ###


### nucleotide sequence ###
# subset nont type II for test
#[]fna_ATfiles = [ f for f in fna_ATfiles if f.find('type_II_') == -1 ]
#[]print(fna_ATfiles)
main(fna_ATfiles, fna_ATmapFile, 'antitoxin')

## toxin fasta vs toxin mapfile 
#[]fna_Tfiles = [ f for f in fna_Tfiles if f.find('type_II_') == -1 ]
#[]print(fna_Tfiles)
main(fna_Tfiles, fna_TmapFile, 'toxin')



 
### amino acid reference  ###

faa_ATmapFile = '/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/antitoxin/encode.map'
faa_TmapFile = '/share/Users/Zehan/Packages/mTAS/database/TADB2/faa/toxin/encode.map'
faa_ATfiles = glob.glob('faa/antitoxin/*.fas')
faa_Tfiles = glob.glob('faa/toxin/*.fas')

#[]faa_Tfiles = [ f for f in faa_Tfiles if f.find('type_II_') == -1 ]
#[]print(faa_Tfiles)
main(faa_Tfiles, faa_TmapFile,'toxin')

#[]faa_ATfiles = [ f for f in faa_ATfiles if f.find('type_II_') == -1 ]
#[]print(faa_Tfiles)
main(faa_ATfiles, faa_ATmapFile,'antitoxin')



