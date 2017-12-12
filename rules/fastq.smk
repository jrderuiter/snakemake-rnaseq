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
            " ".join(config["rules"]["cutadapt"]["extra_pe"])
        threads:
            config["rules"]["cutadapt"]["threads"]
        log:
            "logs/cutadapt/{unit}.log"
        wrapper:
            "file://" + path.join(workflow.basedir, "wrappers", "cutadapt", "pe")
else:
    rule cutadapt:
        input:
            "fastq/raw/{unit}.R1.fastq.gz"
        output:
            fastq=temp("fastq/trimmed/{unit}.R1.fastq.gz"),
            qc="qc/cutadapt/{unit}.txt"
        params:
            " ".join(config["rules"]["cutadapt"]["extra_se"])
        threads:
            config["rules"]["cutadapt"]["threads"]
        log:
            "logs/cutadapt/{unit}.log"
        wrapper:
            "file://" + path.join(workflow.basedir, "wrappers", "cutadapt", "se")
