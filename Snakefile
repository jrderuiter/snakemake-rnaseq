import pandas as pd

if not config:
    raise ValueError("A config file must be provided using --configfile")

def _invert_dict(d):
    return dict( (v,k) for k in d for v in d[k] )

_unit_sample_lookup = _invert_dict(config['samples'])


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

def get_sample_for_unit(unit):
    """Returns sample for given unit."""
    return _unit_sample_lookup[unit]


################################################################################
# Rules                                                                        #
################################################################################

def all_inputs(wildcards):
    inputs = ["feature_counts/merged/normalized_counts.txt",
              "qc/multiqc_report.html"]

    if config["options"]["vardict"]["call_variants"]:
        inputs.append("vardict/final/calls.vcf.gz")

        if config["options"]["vardict"]["flatten_vcf"]:
            inputs.append("vardict/final/calls.txt")

        if config["options"]["vardict"]["annotate_vcf"] == "vep":
            inputs.append("vardict/merged/calls.vep_table.txt")

    return inputs


rule all:
    input: all_inputs
    output: touch(".all")


include: "rules/input.smk"
include: "rules/fastq.smk"
include: "rules/star.smk"
include: "rules/feature_counts.smk"
include: "rules/vardict.smk"
include: "rules/qc.smk"
