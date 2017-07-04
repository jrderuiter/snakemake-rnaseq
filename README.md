# Snakemake workflow: rnaseq

[![Snakemake](https://img.shields.io/badge/snakemake-≥3.13.3-brightgreen.svg)](https://snakemake.bitbucket.io)

This is a Snakemake workflow for generating gene expression counts from
RNA-sequencing data using STAR and featureCounts (from the subread package).

The workflow essentially performs the following steps:

* Cutadapt is used to trim the input reads for adapters and/or poor-quality
  base calls.
* Fastqc is used to perform QC on the trimmed reads.
* The trimmed reads are aligned to the reference genome using STAR.
* The resulting alignments are sorted and indexed using sambamba.
* featureCounts is used to generate gene expression counts.
* The (per sample) counts are merged into a single count file.
* Summary QC statistics are generated using multiqc.

The final output (the merged counts) is located in the tab-separated file
`merged.txt`.

## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/jrderuiter/snakemake-rnaseq/releases).
If you intend to modify and further develop this workflow, fork this repository. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake -n

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100

or

    snakemake --drmaa --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.

## Authors

* Julian de Ruiter (@jrderuiter)
