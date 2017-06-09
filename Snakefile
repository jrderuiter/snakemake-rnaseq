# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.

from os import path
import pandas as pd

configfile: "config.yaml"

################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('samples.tsv', sep='\t')

input_dir = config.get('input_dir', 'fastq')
interim_dir = config.get('interim_dir', 'interim')
qc_dir = config.get('qc_dir', 'qc')
log_dir = config.get('log_dir', 'logs')

trimmed_dir = path.join(interim_dir, 'cutadapt')

################################################################################
# Functions                                                                    #
################################################################################



################################################################################
# Rules                                                                        #
################################################################################

rule all:
    input:
        expand(path.join(trimmed_dir, '{sample}.R1.fastq.gz'), sample=samples['id'])
        # The first rule should define the default target files
        # Subsequent target rules can be specified below. They should start with all_*.


include: "rules/other.smk"


rule cutadapt:
    input:
        path.join(input_dir, '{sample}.R1.fastq.gz')
    output:
        bam=temp(path.join(trimmed_dir, '{sample}.R1.fastq.gz')),
        qc=path.join(qc_dir, 'cutadapt', '{sample}.txt')
    #params:
    #    options=format_options(config['cutadapt']['options'])
    log:
        path.join(log_dir, 'cutadapt', '{sample}.log'),
    shell:
        'cutadapt -o {output.bam}'
        ' {input} > {output.qc} 2> {log}'

