Snakemake-rnaseq
================

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

.. toctree::
   :maxdepth: 2
   :hidden:

   overview
   installation
   configuration
   usage
   contributing
   authors
   history

.. |Snakemake| image:: https://img.shields.io/badge/snakemake-≥3.13.3-brightgreen.svg
   :target: https://snakemake.bitbucket.io

.. |Wercker| image:: https://app.wercker.com/status/9c3bfb4aa4dbffc027b7a0fcfc00cc57/s/develop
   :target: https://app.wercker.com/project/byKey/9c3bfb4aa4dbffc027b7a0fcfc00cc57
