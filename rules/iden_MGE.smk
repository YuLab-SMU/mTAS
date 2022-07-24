ind_contigs = config["oud_contigs"] # oud_contigs: "spades_oud"
oud_MGE = config["oud_MGE"] # oud_MGE: "iden_MGE_oud"
refd_MGE = config["db_MGEdb"]
ths = config["ths"]

rule blast_ICEberg:
    input:
        que = ind_contigs + "/{srr}.fa"
    params:
        refd = refd_MGE
    output:
        oud = directory( oud_MGE + "/{srr}" )
    shell:
        """
        bash utils/batch_iden_MGE.sh {input.que} {params.refd} {output.oud} {ths}
        """
