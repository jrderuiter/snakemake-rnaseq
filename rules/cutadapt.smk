
rule cutadapt:
    input:
        'reads/{sample}.{pair}.fastq.gz'
    output:
        fastq=temp('cutadapt/{sample}.{pair}.fastq.gz'),
        qc='cutadapt/{sample}.{pair}.qc.txt'
    params:
        options=config['cutadapt']['options']
    log:
        path.join('logs/cutadapt/{sample}.{pair}.log'),
    shell:
        'cutadapt {params.options} -o {output.fastq} {input}'
        ' > {output.qc} 2> {log}'
