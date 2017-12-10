from os import path


def multiqc_inputs(wildcards):
    """Returns inputs for multiqc, which vary depending on whether pipeline
       is processing normal or PDX data and whether the data is paired."""

    inputs = [
        expand("qc/fastqc/{unit}.{pair}_fastqc.html",
               unit=get_units(),
               pair=["R1", "R2"] if config["options"]["paired"] else ["R1"]),
        expand("qc/cutadapt/{unit}.txt",
               unit=get_units()),
        expand("qc/samtools_stats/{sample}.txt", sample=get_samples())
    ]

    if config["options"]["pdx"]:
        inputs += [expand("qc/star/disambiguate/{sample}.txt",
                   sample=get_samples())]

    return [input_ for sub_inputs in inputs for input_ in sub_inputs]


rule multiqc:
    input:
        multiqc_inputs
    output:
        "qc/multiqc_report.html"
    params:
        " ".join(config["rules"]["multiqc"]["extra"])
    log:
        "logs/multiqc.log"
    conda:
        path.join(workflow.basedir, "envs/multiqc.yaml")
    wrapper:
        "0.17.4/bio/multiqc"


rule fastqc:
    input:
        "fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz"
    output:
        html="qc/fastqc/{sample}.{lane}.{pair}_fastqc.html",
        zip="qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip"
    params:
        " ".join(config["rules"]["fastqc"]["extra"])
    wrapper:
        "0.17.4/bio/fastqc"


rule samtools_stats:
    input:
        "star/final/{sample}.bam"
    output:
        "qc/samtools_stats/{sample}.txt"
    wrapper:
        "0.17.4/bio/samtools/stats"
