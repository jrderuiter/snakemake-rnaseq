rule multiqc:
    input:
        expand('counts/{sample}.txt', sample=get_samples()),
        fastqc=expand('qc/fastqc/{sample_lane}.{pair}_fastqc.html',
                      sample_lane=get_samples_with_lane(), pair=['R1']),
    output:
        'qc/multiqc_report.html'
    params:
        config['multiqc']['extra']
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/multiqc')


rule fastqc:
    input:
        'fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz'
    output:
        html='qc/fastqc/{sample}.{lane}.{pair}_fastqc.html',
        zip='qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip'
    params:
        config['fastqc']['extra']
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/fastqc')
