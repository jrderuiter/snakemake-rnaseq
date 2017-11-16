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
            temp("star/aligned/{sample}.{lane}.graft/Aligned.out.bam")
        log:
            "logs/star/alignment/{sample}.{lane}.graft.log"
        params:
            index=config["star"]["index"],
            extra=star_extra(config["star"])
        resources:
            memory=30
        threads:
            config["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule star_host:
        input:
            sample=star_inputs
        output:
            temp("star/aligned/{sample}.{lane}.host/Aligned.out.bam")
        log:
            "logs/star/alignment/{sample}.{lane}.host.log"
        params:
            index=config["star"]["index_host"],
            extra=star_extra(config["star"])
        resources:
            memory=30
        threads:
            config["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule sambamba_sort_qname:
        input:
            "star/aligned/{sample}.{lane}.{organism}/Aligned.out.bam"
        output:
            temp("star/sorted/{sample}.{lane}.{organism}.bam")
        params:
            config["sambamba_sort"]["extra"] + " --natural-sort"
        threads:
            config["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    def merge_inputs(wildcards):
        lanes = get_sample_lanes(wildcards.sample)

        file_paths = ["star/sorted/{}.{}.{}.bam".format(
                        wildcards.sample, lane, wildcards.organism)
                    for lane in lanes]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            temp("star/merged/{sample}.{organism}.bam")
        params:
            config["samtools_merge"]["extra"] + " -n"
        threads:
            config["samtools_merge"]["threads"]
        wrapper:
            "0.17.4/bio/samtools/merge"


    rule disambiguate:
        input:
            a="star/merged/{sample}.graft.bam",
            b="star/merged/{sample}.host.bam"
        output:
            a_ambiguous=temp("star/disambiguated/{sample}.graft.ambiguous.bam"),
            b_ambiguous=temp("star/disambiguated/{sample}.host.ambiguous.bam"),
            a_disambiguated=temp("star/disambiguated/{sample}.graft.bam"),
            b_disambiguated=temp("star/disambiguated/{sample}.host.bam"),
            summary="qc/star/disambiguate/{sample}.txt"
        params:
            algorithm="bwa",
            prefix="{sample}",
            extra=config["disambiguate"]["extra"]
        wrapper:
            "0.17.4/bio/ngs-disambiguate"


    rule sambamba_sort_coord:
        input:
            "star/disambiguated/{sample}.graft.bam"
        output:
            "star/final/{sample}.bam"
        params:
            config["sambamba_sort"]["extra"]
        threads:
            config["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    rule samtools_index:
        input:
            "star/final/{sample}.bam"
        output:
            "star/final/{sample}.bam.bai"
        wrapper:
            "0.17.4/bio/samtools/index"
else:
    # 'Standard' alignment rules.
    rule star:
        input:
            sample=star_inputs
        output:
            temp("star/aligned/{sample}.{lane}/Aligned.out.bam")
        log:
            "logs/star/alignment/{sample}.{lane}.log"
        params:
            index=config["star"]["index"],
            extra=star_extra(config["star"])
        resources:
            memory=30
        threads:
            config["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule sambamba_sort:
        input:
            "star/aligned/{sample}.{lane}/Aligned.out.bam"
        output:
            temp("star/sorted/{sample}.{lane}.bam")
        params:
            config["sambamba_sort"]["extra"]
        threads:
            config["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    def merge_inputs(wildcards):
        lanes = get_sample_lanes(wildcards.sample)

        file_paths = ["star/sorted/{}.{}.bam".format(
                        wildcards.sample, lane)
                    for lane in lanes]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            "star/final/{sample}.bam"
        params:
            config["samtools_merge"]["extra"]
        threads:
            config["samtools_merge"]["threads"]
        wrapper:
            "0.17.4/bio/samtools/merge"


    rule samtools_index:
        input:
            "star/final/{sample}.bam"
        output:
            "star/final/{sample}.bam.bai"
        wrapper:
            "0.17.4/bio/samtools/index"
