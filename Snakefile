from os import path
import pandas as pd

configfile: 'config.yaml'

################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('samples.tsv', sep='\t')['id']

################################################################################
# Rules                                                                        #
################################################################################

rule all:
    input:
        'merged.txt',
        'multiqc_report.html'

include: 'rules/cutadapt.smk'
include: 'rules/star.smk'
include: 'rules/counts.smk'
include: 'rules/multiqc.smk'
