from os import path


def star_inputs(wildcards):
    """Returns fastq inputs for star."""

    units = get_sample_units(wildcards.sample)
    base_path = "fastq/trimmed/{unit}.{pair}.fastq.gz"

    inputs = {
        'fastq1': [base_path.format(unit=unit, pair='R1') for unit in units]
    }

    if config["options"]["paired"]:
        inputs['fastq2'] = [base_path.format(unit=unit, pair='R2')
                            for unit in units]

    return inputs


def star_outputs(suffix=""):
    """Outputs for star."""

    base_dir = "star/aligned/{sample}" + suffix

    if config['options']['star_fusion']:
        outputs = [temp(path.join(base_dir, "Aligned.out.bam")),
                   path.join(base_dir, "Chimeric.out.junction")]
    else:
        outputs = temp(path.join(base_dir, "Aligned.out.bam"))

    return outputs


def star_extra(wildcards):
    """Returns extra arguments for STAR based on config."""

    # Specify default arguments.
    defaults = {
        "--outSAMattributes": "NH HI AS nM NM",
        "--outSAMattrRGline": _star_readgroup_str(wildcards),
    }

    if config['options']['star_fusion']:
        fusion_defaults = {
            '--twopassMode': 'Basic',
            '--outReadsUnmapped': 'None',
            '--chimSegmentMin': 12,
            '--chimJunctionOverhangMin': 12,
            '--alignSJDBoverhangMin': 10,
            '--alignMatesGapMax': 100000,
            '--alignIntronMax': 100000,
            '--chimSegmentReadGapMax': 'parameter 3',
            '--alignSJstitchMismatchNmax': '5 -1 5 5'
        }
        defaults = {**defaults, **fusion_defaults}

    arg_str = "".join(config["rules"]["star"]["extra"])
    arg_str = _add_default_args(arg_str, defaults)

    return arg_str


def _star_readgroup_str(wildcards):
    """Returns (default) star readgroup string."""
    fmt_str = ("ID:{sample} SM:{sample} LB:{sample} "
               "PU:{sample} PL:{platform} CN:{centre}")

    return fmt_str.format(
        platform=config["options"]["readgroup"]["platform"],
        centre=config["options"]["readgroup"]["centre"],
        sample=wildcards.sample)


def _add_default_args(arg_str, defaults, delimiter=" "):
    """Adds default arguments into arg string."""

    for key, value in defaults.items():
        if key + delimiter not in arg_str:
            arg_str += " {key}{delim}{value}".format(
                key=key, delim=delimiter, value=value)

    return arg_str


if config["options"]["pdx"]:

    # PDX alignment rules.
    rule star_graft:
        input:
            unpack(star_inputs)
        output:
            star_outputs(suffix='.graft')
        log:
            "logs/star/alignment/{sample}.graft.log"
        params:
            index=config["references"]["star_index"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "file://" + path.join(workflow.basedir, "wrappers/star/align")


    rule star_host:
        input:
            unpack(star_inputs)
        output:
            star_outputs(suffix='.host')
        log:
            "logs/star/alignment/{sample}.host.log"
        params:
            index=config["references"]["star_index_host"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "file://" + path.join(workflow.basedir, "wrappers/star/align")


    rule sambamba_sort_qname:
        input:
            "star/aligned/{sample}.{organism}/Aligned.out.bam"
        output:
            temp("star/sorted/{sample}.{organism}.bam")
        params:
            " ".join(config["rules"]["sambamba_sort"]["extra"] +
                     ["--natural-sort"])
        threads:
            config["rules"]["sambamba_sort"]["threads"]
        wrapper:
            "0.17.4/bio/sambamba/sort"


    rule disambiguate:
        input:
            a="star/sorted/{sample}.graft.bam",
            b="star/sorted/{sample}.host.bam"
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
            " ".join(config["rules"]["sambamba_sort"]["extra"])
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
            star_outputs()
        log:
            "logs/star/alignment/{sample}.log"
        params:
            index=config["references"]["star_index"],
            extra=lambda wc: star_extra(wc)
        resources:
            memory=30
        threads:
            config["rules"]["star"]["threads"]
        wrapper:
            "file://" + path.join(workflow.basedir, "wrappers/star/align")


    rule sambamba_sort:
        input:
            "star/aligned/{sample}/Aligned.out.bam"
        output:
            "star/final/{sample}.bam"
        params:
            " ".join(config["rules"]["sambamba_sort"]["extra"])
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
