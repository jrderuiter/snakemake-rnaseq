if config["options"]["paired"]:
    rule cutadapt:
        input:
            ["fastq/raw/{unit}.R1.fastq.gz",
             "fastq/raw/{unit}.R2.fastq.gz"]
        output:
            fastq1=temp("fastq/trimmed/{unit}.R1.fastq.gz"),
            fastq2=temp("fastq/trimmed/{unit}.R2.fastq.gz"),
            qc="qc/cutadapt/{unit}.txt"
        params:
            config["rules"]["cutadapt_pe"]["extra"]
        log:
            "logs/cutadapt/{unit}.log"
        wrapper:
            "0.17.4/bio/cutadapt/pe"
else:
    rule cutadapt:
        input:
            "fastq/raw/{unit}.R1.fastq.gz"
        output:
            fastq=temp("fastq/trimmed/{unit}.R1.fastq.gz"),
            qc="qc/cutadapt/{unit}.txt"
        params:
            config["rules"]["cutadapt_se"]["extra"]
        log:
            "logs/cutadapt/{unit}.log"
        wrapper:
            "0.17.4/bio/cutadapt/se"
