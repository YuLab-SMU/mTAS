ind_contigs = config["oud_contigs"]
oud_TA  = config["oud_TA"] 
db_ref_AT = config['db_ref_AT']
db_ref_T = config['db_ref_AT']
# in config.yaml
#db_ref_AT: 'database/TADB2/fna/antitoxin/merge2.fna'
#db_map_AT: 'database/TADB2/fna/antitoxin/encode.map.2'
#db_ref_T: 'database/TADB2/faa/toxin/merge2.fna'
#db_map_T: 'database/TADB2/faa/toxin/encode.map.2'
ths = config['ths']
# in snakefile 
#(SRR,) = glob_wildcards(dir_reads + "{srr}.reads.fa" )


rule blast_ATref:
    input:
        query = ind_contigs + "/{srr}.fa"
    output:
        oud = directory( oud_TA +"/antitoxin/{srr}" ) #
    shell:
        """
        bash utils/blastn_wrapper.sh -i {input.query} -r {db_ref_AT} -O {output.oud}
        """

rule blast_Tref:
    input:
        query = ind_contigs + "/{srr}.fa"
    output:
        oud = directory( oud_TA +"/toxin/{srr}" )
    shell:
        """
        bash utils/diamond_blastx_wrapper.sh -i {input.query} -r {db_ref_T} -O {output.oud}
        """

