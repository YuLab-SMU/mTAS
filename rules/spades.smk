ind_reads = config["oud_reads"]
oud_contigs = config["oud_contigs"]
scrp = "utils/spades.sh"
ths = config["ths"]


rule run_spades:
    input:
        fq1 = ind_reads + "{srr}_1.fastq",
        fq2 = ind_reads + "{srr}_2.fastq"
    output:
        oud_contigs + "{srr}.fa"
    shell:
        "bash {scrp} "
        "-i {input.fq1},{input.fq2} -d {oud_contigs} -t {ths} -o {output}"

