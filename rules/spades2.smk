# This is the single read version of spades.smk
# you may also run the wrapper script utils/02spades.sh, or spades and other assembler

ind = "01clean_reads/"
oud = "02spades_oud/"
scrp = "utils/02spades.sh"

rule run_spades:
    input:
        input_folder + "{srr}.fastq",
    output:
        oud + "{srr}.fa"
    shell:
        "bash {scrp} "
        "-i {input} -d {oud} -t `nproc` -o {output}"

