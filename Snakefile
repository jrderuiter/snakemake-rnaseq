import pandas as pd

configfile: 'config.yaml'


################################################################################
# Globals                                                                      #
################################################################################

samples = pd.read_csv('samples.tsv', sep='\t')
is_paired = "fastq2" in samples.columns


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

def all_inputs(wildcards):
    inputs = ["feature_counts/merged/normalized_counts.txt",
              "qc/multiqc_report.html"]

    if config["options"]["vardict"]:
        inputs.append("vardict/merged/calls.vcf.gz")

    return inputs


rule all:
    input: all_inputs


include: "rules/input.smk"
include: "rules/fastq.smk"
include: "rules/star.smk"
include: "rules/feature_counts.smk"
include: "rules/vardict.smk"
include: "rules/qc.smk"
