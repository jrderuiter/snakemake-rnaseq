rule multiqc:
    input:
        expand("qc/feature_counts/{sample}.txt", sample=get_samples()),
        expand("qc/fastqc/{sample_lane}.{pair}_fastqc.html",
               sample_lane=get_samples_with_lane(),
               pair=["R1", "R2"] if paired else ["R1"])
    output:
        "qc/multiqc_report.html"
    params:
        config["multiqc"]["extra"]
    log:
        "logs/multiqc.log"
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
