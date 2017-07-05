Overview
========

The workflow can be run in two modes: the 'standard' workflow (for normal
sequencing) data and a 'PDX' workflow, which handles host/graft read separation
for patient-derived xenograft samples.

Standard workflow
-----------------

The standard (non-PDX) workflow essentially performs the following steps:

* Cutadapt is used to trim the input reads for adapters and/or poor-quality
  base calls.
* The trimmed reads are aligned to the reference genome using STAR.
* The resulting alignments are sorted and indexed using sambamba.
* featureCounts is used to generate gene expression counts.
* The (per sample) counts are merged into a single count file.
* The merged counts are normalized for differences in sequencing depth (using
  DESeq's median-of-ratios approach) and log-transformed.

QC statistics are generated using fastqc and samtools stats. The stats are
summarized into a single report using multiqc.

Altogether, this results in the following dependency graph:

.. figure:: images/dag.svg
  :align: center


PDX workflow
------------

The PDX workflow is a slightly modified version of the standard workflow, which
aligns the reads to two reference genome (the host and graft reference genomes)
and uses disambiguate_ to remove sequences originating from the host organism.
For typical PDX samples, this means removing the mouse (host) reads, leaving
the human (graft) reads for further analysis.

The PDX workflow adds the following additional steps:

* The reads are aligned to two references in ``star_host`` and ``star_graft``.
* The resulting alignments are sorted by queryname using samtools and
  subsequently 'disambiguated' using the disamgibuate tool from AstraZeneca.
* The disambiguated alignments are sorted by coordinate using sambamba.

This results in the following dependency graph:

.. figure:: images/dag_pdx.svg
  :align: center

.. _disambiguate: https://github.com/AstraZeneca-NGS/disambiguate
