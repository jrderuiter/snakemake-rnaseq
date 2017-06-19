rule star:
    input:
        sample=['fastq/trimmed/{sample}.{lane}.R1.fastq.gz']
    output:
        temp('bam/star/{sample}.{lane}/Aligned.out.bam')
    log:
        'logs/star/{sample}.{lane}.log'
    params:
        index=config['star']['index'],
        extra=config['star']['extra']
    threads:
        config['star']['threads']
    wrapper:
        '0.15.4/bio/star/align'


rule sambamba_sort:
    input:
        'bam/star/{sample}.{lane}/Aligned.out.bam'
    output:
        'bam/sorted/{sample}.{lane}.bam'
    params:
        config['sambamba_sort']['extra']
    threads:
        config['sambamba_sort']['threads']
    wrapper:
        '0.15.4/bio/sambamba/sort'


def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = ['bam/sorted/{}.{}.bam'.format(
                    wildcards.sample, lane)
                  for lane in lanes]

    return file_paths


rule picard_merge_bam:
    input:
        merge_inputs
    output:
        'bam/merged/{sample}.bam'
    params:
        config['picard_merge_bam']['extra']
    log:
        'logs/picard_merge_bam/{sample}.log'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/picard/mergesamfiles')


rule samtools_index:
    input:
        'bam/merged/{sample}.bam'
    output:
        'bam/merged/{sample}.bam.bai'
    wrapper:
        '0.15.4/bio/samtools/index'
