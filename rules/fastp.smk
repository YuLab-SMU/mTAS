ind_reads = config["ind_reads"]
oud_reads = config["oud_reads"]
corr = config["corr"] 
wsize = config["win_size"]
ths = config["ths"]

rule run_fastp:
    input:
        fq1 = ind_reads + "/{srr}_1.fastq",
        fq2 = ind_reads + "/{srr}_2.fastq"
    output:
        fq1 = oud_reads + "/{srr}_1.fastq",
        fq2 = oud_reads  + "/{srr}_2.fastq",
        json = oud_reads + "/{srr}.json",
        html = oud_reads + "/{srr}.html"
    shell:
        """
        fastp -c {corr} -W {wsize} \
	    --thread {ths} \
            --in1 {input.fq1} \
            --in2 {input.fq2} \
            --out1 {output.fq1} \
            --out2 {output.fq2} \
            -h {output.html} \
            --json {output.json}
        """
