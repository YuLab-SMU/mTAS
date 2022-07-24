# virus/plasmid prediction using viralVerify
ind_contigs = config["oud_contigs"]
oud_vV = config["oud_vV"]
ths = config["ths"]
HMM = config["db_hmm"] #database/Pfam/Pfam-A.31.0.hmm

rule run_viralVerify:
    input:
        inf = ind_contigs + "{srr}.fa"
    output:
        oud = directory( oud_vV + "{srr}" )
    shell:
        "viralverify.py -f {input.inf} "
        "-o {output.oud} "
        "--hmm {HMM} "
        "-t {ths} -p"
