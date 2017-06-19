from os import path

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider


HTTP = HTTPRemoteProvider()


def fastq_input(wildcards):
    # Lookup input paths.
    key = (wildcards.sample, wildcards.lane)
    row = samples.set_index(['sample', 'lane']).loc[key]

    if wildcards.pair == 'R1':
        input_ = row['fastq1']
    elif wildcards.pair == 'R2':
        input_ = row['fastq2']
    else:
        raise ValueError('Unexpected value for pair ({})'
                         .format(wildcards.pair))

    # Wrap as URL if needed.
    if input_.startswith('http'):
        input_ = HTTP.remote(input_)

    return input_


rule fetch_fastq:
    input:
        fastq_input
    output:
        temp('fastq/input/{sample}.{lane}.{pair}.fastq.gz')
    shell:
        'cp {input} {output}'


rule cutadapt:
    input:
        'fastq/input/{sample}.{lane}.R1.fastq.gz'
    output:
        fastq='fastq/trimmed/{sample}.{lane}.R1.fastq.gz',
        qc='qc/cutadapt/{sample}.{lane}.qc.txt'
    params:
        config['cutadapt']['extra']
    log:
        'logs/cutadapt/{sample}.{lane}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/cutadapt/se')
