import pandas as pd

configfile: 'config.json'


################################################################################
# Functions                                                                    #
################################################################################

def get_samples():
    """Returns list of all samples."""
    return list(config["samples"].keys())

def get_units():
    """Returns list of units."""
    return list(config["units"].keys())

def get_sample_units(sample):
    """Returns lanes for given sample."""
    return config["samples"][sample]

# def get_samples_with_lane():
#     """Returns list of all combined lane/sample identifiers."""
#     # TODO: Check if this is correct.
#     return list(config["units"].keys())


################################################################################
# Rules                                                                        #
################################################################################

def all_inputs(wildcards):
    inputs = ["feature_counts/merged/normalized_counts.txt",
              "qc/multiqc_report.html"]

    if config["options"]["vardict"]:
        inputs.append("vardict/final/calls.vcf.gz")

        if config["options"]["flatten_vcf"]:
            inputs.append("vardict/final/calls.txt")

        if config["options"]["annotate_vcf"] == "vep":
            inputs.append("vardict/merged/calls.vep_table.txt")

    return inputs


rule all:
    input: all_inputs


include: "rules/input.smk"
include: "rules/fastq.smk"
include: "rules/star.smk"
include: "rules/feature_counts.smk"
include: "rules/vardict.smk"
include: "rules/qc.smk"
