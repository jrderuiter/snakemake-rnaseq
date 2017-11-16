def star_inputs(wildcards):
    """Returns fastq inputs for star."""

    base_path = "fastq/trimmed/{sample}.{lane}.{{pair}}.fastq.gz".format(
        sample=wildcards.sample, lane=wildcards.lane)
    pairs = ["R1", "R2"] if is_paired else ["R1"]

    return expand(base_path, pair=pairs)


def star_extra(star_config):
    """Returns extra arguments for STAR based on config."""

    extra = star_config.get("extra", "")

    # Add readgroup information.
    extra_args = "--outSAMattrRGline " + star_config["readgroup"]

    # Add NM SAM attribute (required for PDX pipeline).
    if "--outSamAttributes" not in extra:
        extra_args += " --outSAMattributes NH HI AS nM NM"

    # Add any extra args passed by user.
    if extra:
        extra_args += " " + extra

    return extra_args


if config["options"]["pdx"]:

    # PDX alignment rules.
    rule star_graft:
        input:
            sample=star_inputs
        output:
            temp("bam/star/{sample}.{lane}.graft/Aligned.out.bam")
        log:
            "logs/star/{sample}.{lane}.log"
        params:
            index=config["star"]["index"],
            extra=star_extra(config["star"])
        resources:
            memory=30
        threads:
            config["star"]["threads"]
        wrapper:
            "0.17.0/bio/star/align"


    rule star_host:
        input:
            sample=star_inputs
        output:
            temp("bam/star/{sample}.{lane}.host/Aligned.out.bam")
        log:
            "logs/star/{sample}.{lane}.log"
        params:
            index=config["star"]["index_host"],
            extra=star_extra(config["star"])
        resources:
            memory=30
        threads:
            config["star"]["threads"]
        wrapper:
            "0.17.0/bio/star/align"


    rule sambamba_sort_qname:
        input:
            "bam/star/{sample}.{lane}.{organism}/Aligned.out.bam"
        output:
            temp("bam/star/{sample}.{lane}.{organism}/Aligned.sorted.bam")
        params:
            config["sambamba_sort"]["extra"] + " --natural-sort"
        threads:
            config["sambamba_sort"]["threads"]
        wrapper:
            "0.17.0/bio/sambamba/sort"


    def merge_inputs(wildcards):
        lanes = get_sample_lanes(wildcards.sample)

        file_paths = ["bam/star/{}.{}.{}/Aligned.sorted.bam"
                    .format(wildcards.sample, lane, wildcards.organism)
                    for lane in lanes]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            temp("bam/merged/{sample}.{organism}.bam")
        params:
            config["samtools_merge"]["extra"] + " -n"
        threads:
            config["samtools_merge"]["threads"]
        wrapper:
            "0.17.0/bio/samtools/merge"


    rule disambiguate:
        input:
            a="bam/merged/{sample}.graft.bam",
            b="bam/merged/{sample}.host.bam"
        output:
            a_ambiguous=temp("bam/disambiguate/{sample}.graft.ambiguous.bam"),
            b_ambiguous=temp("bam/disambiguate/{sample}.host.ambiguous.bam"),
            a_disambiguated=temp("bam/disambiguate/{sample}.graft.bam"),
            b_disambiguated=temp("bam/disambiguate/{sample}.host.bam"),
            summary="qc/disambiguate/{sample}.txt"
        params:
            algorithm="bwa",
            prefix="{sample}",
            extra=config["disambiguate"]["extra"]
        wrapper:
            "0.17.0/bio/ngs-disambiguate"


    rule sambamba_sort_coord:
        input:
            "bam/disambiguate/{sample}.graft.bam"
        output:
            "bam/final/{sample}.bam"
        params:
            config["sambamba_sort"]["extra"]
        threads:
            config["sambamba_sort"]["threads"]
        wrapper:
            "0.17.0/bio/sambamba/sort"


    rule samtools_index:
        input:
            "bam/final/{sample}.bam"
        output:
            "bam/final/{sample}.bam.bai"
        wrapper:
            "0.17.0/bio/samtools/index"
else:
    # 'Standard' alignment rules.
    rule star:
        input:
            sample=star_inputs
        output:
            temp("bam/star/{sample}.{lane}/Aligned.out.bam")
        log:
            "logs/star/{sample}.{lane}.log"
        params:
            index=config["star"]["index"],
            extra=star_extra(config["star"])
        resources:
            memory=30
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
            "bam/final/{sample}.bam"
        params:
            config["samtools_merge"]["extra"]
        threads:
            config["samtools_merge"]["threads"]
        wrapper:
            "0.17.0/bio/samtools/merge"


    rule samtools_index:
        input:
            "bam/final/{sample}.bam"
        output:
            "bam/final/{sample}.bam.bai"
        wrapper:
            "0.17.0/bio/samtools/index"
