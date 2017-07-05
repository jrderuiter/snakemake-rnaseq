if is_paired:
    rule cutadapt:
        input:
            ["fastq/raw/{sample}.{lane}.R1.fastq.gz",
             "fastq/raw/{sample}.{lane}.R2.fastq.gz"]
        output:
            fastq1=temp("fastq/trimmed/{sample}.{lane}.R1.fastq.gz"),
            fastq2=temp("fastq/trimmed/{sample}.{lane}.R2.fastq.gz"),
            qc="qc/cutadapt/{sample}.{lane}.txt"
        params:
            config["cutadapt_pe"]["extra"]
        log:
            "logs/cutadapt/{sample}.{lane}.log"
        wrapper:
            "0.17.0/bio/cutadapt/pe"
else:
    rule cutadapt:
        input:
            "fastq/raw/{sample}.{lane}.R1.fastq.gz"
        output:
            fastq=temp("fastq/trimmed/{sample}.{lane}.R1.fastq.gz"),
            qc="qc/cutadapt/{sample}.{lane}.txt"
        params:
            config["cutadapt_se"]["extra"]
        log:
            "logs/cutadapt/{sample}.{lane}.log"
        wrapper:
            "0.17.0/bio/cutadapt/se"
