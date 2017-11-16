from os import path


def multiqc_inputs(wildcards):
    """Returns inputs for multiqc, which vary depending on whether pipeline
       is processing normal or PDX data and whether the data is paired."""

    inputs = [
        expand("qc/fastqc/{sample_lane}.{pair}_fastqc.html",
               sample_lane=get_samples_with_lane(),
               pair=["R1", "R2"] if is_paired else ["R1"]),
        expand("qc/cutadapt/{sample_lane}.txt",
               sample_lane=get_samples_with_lane()),
        expand("qc/samtools_stats/{sample}.txt", sample=get_samples())
    ]

    if config["options"]["pdx"]:
        inputs += [expand("qc/disambiguate/{sample}.txt", sample=get_samples())]

    return [input_ for sub_inputs in inputs for input_ in sub_inputs]


rule multiqc:
    input:
        multiqc_inputs
    output:
        "qc/multiqc_report.html"
    params:
        config["multiqc"]["extra"]
    log:
        "logs/multiqc.log"
    conda:
        path.join(workflow.basedir, "envs/multiqc.yaml")
    wrapper:
        "0.17.0/bio/multiqc"


rule fastqc:
    input:
        "fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz"
    output:
        html="qc/fastqc/{sample}.{lane}.{pair}_fastqc.html",
        zip="qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip"
    params:
        config["fastqc"]["extra"]
    wrapper:
        "0.17.0/bio/fastqc"


rule samtools_stats:
    input:
        "bam/final/{sample}.bam"
    output:
        "qc/samtools_stats/{sample}.txt"
    wrapper:
        "0.17.0/bio/samtools/stats"
