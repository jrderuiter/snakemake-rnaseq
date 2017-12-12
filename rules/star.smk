def star_inputs(wildcards):
    """Returns fastq inputs for star."""

    base_path = "fastq/trimmed/{unit}.{{pair}}.fastq.gz".format(
        unit=wildcards.unit)
    pairs = ["R1", "R2"] if config["options"]["paired"] else ["R1"]

    return expand(base_path, pair=pairs)


def star_extra(wildcards):
    """Returns extra arguments for STAR based on config."""

    star_config = config["rules"]["star"]

    extra_user = star_config.get("extra", [])
    extra_args  = []

    # Add readgroup information.
    if not any(arg.startswith("--outSAMattrRGline") for arg in extra_user):
        readgroup_str = ("ID:{unit} SM:{sample} LB:{sample} "
                         "PU:{unit} PL:{platform} CN:{centre}")

        readgroup_str = readgroup_str.format(
            platform=config["options"]["readgroup"]["platform"],
            centre=config["options"]["readgroup"]["centre"],
            unit=wildcards.unit,
            sample=get_sample_for_unit(wildcards.unit))

        extra_args.append("--outSAMattrRGline " + readgroup_str)

    # Add NM SAM attribute (required for PDX pipeline).
    if not any(arg.startswith("--outSamAttributes") for arg in extra_user):
        extra_args.append("--outSAMattributes NH HI AS nM NM")

    # Add any extra args passed by user.
    if extra_user:
        extra_args += extra_user

    return " ".join(extra_args)


if config["options"]["pdx"]:

    # PDX alignment rules.
    rule star_graft:
        input:
            sample=star_inputs
        output:
            temp("star/aligned/{unit}.graft/Aligned.out.bam")
        log:
            "logs/star/alignment/{unit}.graft.log"
        params:
            index=config["references"]["star_index"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule star_host:
        input:
            sample=star_inputs
        output:
            temp("star/aligned/{unit}.host/Aligned.out.bam")
        log:
            "logs/star/alignment/{unit}.host.log"
        params:
            index=config["references"]["star_index_host"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule sambamba_sort_qname:
        input:
            "star/aligned/{unit}.{organism}/Aligned.out.bam"
        output:
            temp("star/sorted/{unit}.{organism}.bam")
        params:
            " ".join(config["rules"]["sambamba_sort"]["extra"] +
                     ["--natural-sort"])
        threads:
            config["rules"]["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    def merge_inputs(wildcards):
        units = get_sample_units(wildcards.sample)

        file_paths = ["star/sorted/{}.{}.bam".format(
                      unit, wildcards.organism)
                    for unit in units]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            temp("star/merged/{sample}.{organism}.bam")
        params:
            " ".join(config["rules"]["samtools_merge"]["extra"] + ["-n"])
        threads:
            config["rules"]["samtools_merge"]["threads"]
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
            extra=config["rules"]["disambiguate"]["extra"]
        wrapper:
            "0.17.4/bio/ngs-disambiguate"


    rule sambamba_sort_coord:
        input:
            "star/disambiguated/{sample}.graft.bam"
        output:
            "star/final/{sample}.bam"
        params:
            config["rules"]["sambamba_sort"]["extra"]
        threads:
            config["rules"]["sambamba_sort"]["threads"]
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
            temp("star/aligned/{unit}/Aligned.out.bam")
        log:
            "logs/star/alignment/{unit}.log"
        params:
            index=config["references"]["star_index"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "0.17.4/bio/star/align"


    rule sambamba_sort:
        input:
            "star/aligned/{unit}/Aligned.out.bam"
        output:
            temp("star/sorted/{unit}.bam")
        params:
            " ".join(config["rules"]["sambamba_sort"]["extra"])
        threads:
            config["rules"]["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    def merge_inputs(wildcards):
        units = get_sample_units(wildcards.sample)

        file_paths = ["star/sorted/{}.bam".format(unit)
                      for unit in units]

        return file_paths


    rule samtools_merge:
        input:
            merge_inputs
        output:
            "star/final/{sample}.bam"
        params:
            " ".join(config["rules"]["samtools_merge"]["extra"])
        threads:
            config["rules"]["samtools_merge"]["threads"]
        wrapper:
            "0.17.4/bio/samtools/merge"


    rule samtools_index:
        input:
            "star/final/{sample}.bam"
        output:
            "star/final/{sample}.bam.bai"
        wrapper:
            "0.17.4/bio/samtools/index"
