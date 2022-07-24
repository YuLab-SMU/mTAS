# config files 
configfile: "config/config.yaml"
configfile: "config/params.yaml"
configfile: "config/IO.yaml"

# initial read 
ind_reads = config["ind_reads"]
SRR,R = glob_wildcards( ind_reads + "/{srr}_{r}.fastq")

# final output 
rule all:
    input: 
        expand( config["oud_reads"] + "/{srr}_{r}.fastq", srr=SRR, r=R ),
        expand( config["oud_contigs"] + "/{srr}.fa", srr=SRR),
        expand( config["oud_vV"] + "/{srr}", srr=SRR),
        expand( config["oud_TA"] + "/antitoxin/{srr}", srr=SRR ),
        expand( config["oud_TA"] + "/toxin/{srr}", srr=SRR ),
        expand( config["oud_MGE"] + "/{srr}", srr=SRR )

include: "rules/fastp.smk"
include: "rules/spades.smk"
include: "rules/viralVerify.smk"
include: "rules/blast_TADB2.smk"
include: "rules/iden_MGE.smk"

