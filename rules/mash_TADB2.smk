dir_output="/share/Users/Zehan/Packages/mTAS/mTAS-dev0.2/04-5mash_TA_HTS/"
ATref="/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/antitoxin/merge2.fna" 
Tref="/share/Users/Zehan/Packages/mTAS/database/TADB2/fna/toxin/merge2.fna"
dir_reads="/share/Users/Zehan/Packages/mTAS/mTAS-dev0.1/test/mapping/"

dir_output1 = dir_output + "sketch_oud/"
dir_output2 = dir_output + "screen_oud/"

ths_mash = 72


(SRR,) = glob_wildcards(dir_reads + "{srr}.reads.fa" )

rule all:
    input:
        expand( dir_output1 + "{srr}.reads.fa.msh", srr=SRR ),
        dir_output1 + "Tref.msh",
        dir_output1 + "ATref.msh",        
        expand( dir_output2 + "{srr}_TADB2_T.tsv", srr=SRR ), 
        expand( dir_output2 + "{srr}_TADB2_AT.tsv", srr=SRR ),
        expand( dir_output2 + "{srr}_TADB2_T.tsv2", srr=SRR ),
        expand( dir_output2 + "{srr}_TADB2_AT.tsv2", srr=SRR )


rule sketch_ref:
    input:
        Tmsh = {Tref},
        ATmsh = {ATref}
    output:
        Tmsh=dir_output1+"Tref.msh",
        ATmsh=dir_output1+"ATref.msh"
    shell:
        """
        mash sketch -o {output.Tmsh} -p {ths_mash} {input.Tmsh}
        mash sketch -o {output.ATmsh} -p {ths_mash} {input.ATmsh}
        """

rule sketch_reads:
    input:
        read= dir_reads + "{srr}.reads.fa"
    output:
        readmsh = dir_output1 + "{srr}.reads.fa.msh"   
    shell:
        "mash sketch -o {output.readmsh} -p {ths_mash} {input.read}" 



rule screen:
    input :
        Tmsh=dir_output1+"Tref.msh",
        ATmsh=dir_output1+"ATref.msh",
        read_msh = dir_output1 + "{srr}.reads.fa.msh",
        read = dir_reads + "{srr}.reads.fa"
    output:    
        ouf1 = dir_output2 + "{srr}_TADB2_T.tsv",
        ouf2 = dir_output2 + "{srr}_TADB2_AT.tsv",
        ouf3 = dir_output2 + "{srr}_TADB2_T.tsv2",
        ouf4 = dir_output2 + "{srr}_TADB2_AT.tsv2"
    shell: 
        """
        mash screen -p {ths_mash} {input.read_msh} {Tref} > {output.ouf1} 
        mash screen -p {ths_mash} {input.read_msh} {ATref} > {output.ouf2}
        mash screen -p {ths_mash} {input.Tmsh} {input.read} > {output.ouf3}
        mash screen -p {ths_mash} {input.ATmsh} {input.read} > {output.ouf4} 
        """

rule run_blastn:
    input :
        Tref=dir_output1+"{Tref}",
        ATref=dir_output1+"{ATref}",
        contigs = dir_output1 + "{srr}.contigs.fa"
    output:
        ouf1 = dir_output2 + "{srr}_TADB2_T.tsv"
    params: 
        fmt = '6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen stitle qacc qseqid'
    shell:
        """
        blastn -query {contigs} -db {input.Tref} -out {output.ouf1} \
                -outfmt {params} \
                -num_threads {ths} \
                -word_size 21
        """

rule run_blastn:
    input:
        Tref=dir_output1+"{Tref}",
        ATref=dir_output1+"{ATref}",
        contigs = dir_output1 + "{srr}.contigs.fa"
    output:
        ouf1 = dir_output2 + "{srr}_TADB2_T.tsv"
    shell:
        """
        bash utils/blastn_wrapper.sh -i {contigs} -r {input.Tref} -o  {output.ouf1}  
        """

