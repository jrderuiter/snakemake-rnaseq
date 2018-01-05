__author__ = "Johannes Köster"
__copyright__ = "Copyright 2016, Johannes Köster"
__email__ = "koester@jimmy.harvard.edu"
__license__ = "MIT"

import os
from snakemake.shell import shell

# Extract fastq paths and convert to concatenated str.
fastq_str = ",".join(snakemake.input.fastq1)

if hasattr(snakemake.input, "fastq2"):
    fastq_str += " " + ",".join(snakemake.input.fastq2)

# Determine if we need to use gzip.
if snakemake.input.fastq1[0].endswith(".gz"):
    readcmd = "--readFilesCommand zcat"
else:
    readcmd = ""

# Extract other arguments.
outprefix = os.path.dirname(snakemake.output[0]) + "/"
extra = snakemake.params.get("extra", "")
log = snakemake.log_fmt_shell(stdout=True, stderr=True)

# Run STAR.
shell("STAR "
      "{snakemake.params.extra} "
      "--runThreadN {snakemake.threads} "
      "--genomeDir {snakemake.params.index} "
      "--readFilesIn {fastq_str} "
      "{readcmd} "
      "--outSAMtype BAM Unsorted "
      "--outFileNamePrefix {outprefix} "
      "--outStd Log "
      "{log}")
