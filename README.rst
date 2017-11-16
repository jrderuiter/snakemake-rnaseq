Snakemake-exome
===============

|Snakemake| |Wercker|

This is a Snakemake workflow for generating gene expression counts from
RNA-sequencing data using STAR and featureCounts (from the subread package).
The workflow is designed to handle both single-end and paired-end sequencing
data, as well as sequencing data from multiple lanes. Processing of
patient-derived xenograft (PDX) samples is also supported, by using
disambiguate to separate graft/host sequence reads.

If you use this workflow in a paper, don't forget to give credits
to the authors by citing the URL of this repository and, if available, its
DOI (see above).

.. |Snakemake| image:: https://img.shields.io/badge/snakemake-≥3.13.3-brightgreen.svg
   :target: https://snakemake.bitbucket.io

.. |Wercker| image:: https://app.wercker.com/status/9c3bfb4aa4dbffc027b7a0fcfc00cc57/s/develop
   :target: https://app.wercker.com/project/byKey/9c3bfb4aa4dbffc027b7a0fcfc00cc57

Overview
--------

The standard (non-PDX) workflow essentially performs the following steps:

* Cutadapt is used to trim the input reads for adapters and/or poor-quality
  base calls.
* The trimmed reads are aligned to the reference genome using STAR.
* The resulting alignments are sorted and indexed using sambamba.
* featureCounts is used to generate gene expression counts.
* The (per sample) counts are merged into a single count file.
* The merged counts are normalized for differences in sequencing depth (using
  DESeq's median-of-ratios approach) and log-transformed.

This results in the following dependency graph:

.. image:: https://jrderuiter.github.io/snakemake-rnaseq/_images/dag.svg

The PDX workflow is a slightly modified version of the standard workflow, which
aligns the reads to two reference genome (the host and graft reference genomes)
and uses disambiguate_ to remove sequences originating from the host organism.
See the documentation for more details.

Documentation
-------------

Documentation is available at: http://jrderuiter.github.io/snakemake-rnaseq.

License
-------

This software is released under the MIT license.

.. _disambiguate: https://github.com/AstraZeneca-NGS/disambiguate
