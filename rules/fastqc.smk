
rule fastqc:
    input:
        'cutadapt/{sample}.{pair}.fastq.gz'
    output:
        'fastqc/{sample}.{pair}_fastqc.zip'
    params:
        output_dir='fastqc'
    shell:
        'mkdir -p {params.output_dir} && '
        'fastqc --quiet --outdir {params.output_dir} {input}'
