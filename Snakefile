import pandas as pd

configfile: 'config.yaml'


################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('samples.tsv', sep='\t')
is_paired = config["general"].get("paired", False)
is_pdx = config["general"].get("pdx", False)


################################################################################
# Functions                                                                    #
################################################################################

def get_samples():
    """Returns list of all samples."""
    return list(samples["sample"].unique())


def get_samples_with_lane():
    """Returns list of all combined lane/sample identifiers."""
    return list((samples["sample"] + "." + samples["lane"]).unique())


def get_sample_lanes(sample):
    """Returns lanes for given sample."""
    subset = samples.loc[samples["sample"] == sample]
    return list(subset["lane"].unique())


################################################################################
# Rules                                                                        #
################################################################################

rule all:
    input:
        "counts/merged/counts.log2.txt",
        "qc/multiqc_report.html"

include: "rules/input.smk"
include: "rules/fastq.smk"
include: "rules/counts.smk"
include: "rules/qc.smk"

if is_pdx:
    include: "rules/alignment_pdx.smk"
else:
    include: "rules/alignment.smk"

