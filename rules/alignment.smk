def star_inputs(wildcards):
    base_path = "fastq/trimmed/{sample}.{lane}.{{pair}}.fastq.gz".format(
        sample=wildcards.sample, lane=wildcards.lane)
    pairs = ["R1", "R2"] if paired else ["R1"]
    return expand(base_path, pair=pairs)


rule star:
    input:
        sample=star_inputs
    output:
        temp("bam/star/{sample}.{lane}/Aligned.out.bam")
    log:
        "logs/star/{sample}.{lane}.log"
    params:
        index=config["star"]["index"],
        extra=config["star"]["extra"]
    threads:
        config["star"]["threads"]
    wrapper:
        "0.17.0/bio/star/align"


rule sambamba_sort:
    input:
        "bam/star/{sample}.{lane}/Aligned.out.bam"
    output:
        "bam/sorted/{sample}.{lane}.bam"
    params:
        config["sambamba_sort"]["extra"]
    threads:
        config["sambamba_sort"]["threads"]
    wrapper:
        "0.17.0/bio/sambamba/sort"


def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = ["bam/sorted/{}.{}.bam".format(
                    wildcards.sample, lane)
                  for lane in lanes]

    return file_paths


rule samtools_merge:
    input:
        merge_inputs
    output:
        "bam/merged/{sample}.bam"
    params:
        config["samtools_merge"]["extra"]
    threads:
        config["samtools_merge"]["threads"]
    wrapper:
        "0.17.0/bio/samtools/merge"


rule samtools_index:
    input:
        "bam/merged/{sample}.bam"
    output:
        "bam/merged/{sample}.bam.bai"
    wrapper:
        "0.17.0/bio/samtools/index"
