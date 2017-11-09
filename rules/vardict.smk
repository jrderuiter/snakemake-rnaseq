
rule vardict:
    input:
        bam="star/final/{sample}.bam",
        bai="star/final/{sample}.bam.bai",
        reference=config["vardict"]["reference"],
        regions=config["vardict"]["regions"]
    output:
        temp("vardict/per_sample/{sample}.vcf")
    params:
        options=config["vardict"]["extra"],
        options_vcf=config["vardict"]["extra_vcf"],
        sample="{sample}"
    shell:
        "vardict -G {input.reference} -b {input.bam} -N {params.sample}"
        " {params.options} {input.regions}"
        " | teststrandbias.R"
        " | var2vcf_valid.pl -N {params.sample} {params.options_vcf}"
        " > {output}"


rule vardict_tabix:
    input:
        "vardict/per_sample/{sample}.vcf"
    output:
        "vardict/per_sample/{sample}.vcf.gz",
        "vardict/per_sample/{sample}.vcf.gz.tbi"
    shell:
        "bgzip -c {input[0]} > {output[0]} && tabix -p vcf {output[0]}"


rule vardict_merge:
    input:
        expand("vardict/per_sample/{sample}.vcf.gz", sample=get_samples())
    output:
        "vardict/merged/calls.vcf.gz"
    params:
        options=config["vardict_merge"]["extra"]
    shell:
        "bcftools merge -z {params.options} {input} > {output[0]}"
        " && tabix -p vcf {output[0]}"
