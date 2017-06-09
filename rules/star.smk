
rule star:
    input:
        sample=['cutadapt/{sample}.R1.fastq.gz']
    output:
        temp('star/{sample}/Aligned.out.bam')
    log:
        'logs/star/{sample}.log'
    params:
        index=config['star']['index'],
        extra=config['star']['extra']
    threads: 8
    wrapper:
        '0.15.4/bio/star/align'

rule sambamba_sort:
    input:
        'star/{sample}/Aligned.out.bam'
    output:
        'star/{sample}/Aligned.sortedByCoord.out.bam'
    params: ''
    threads: 8
    wrapper:
        '0.15.4/bio/sambamba/sort'

rule sambamba_index:
    input:
        'star/{sample}/Aligned.sortedByCoord.out.bam'
    output:
        'star/{sample}/Aligned.sortedByCoord.out.bam.bai'
    shell:
        'sambamba index -t {threads} {input} {output}'
