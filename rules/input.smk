from os import path

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider


HTTP = HTTPRemoteProvider()
FTP = FTPRemoteProvider(**config["input"].get("ftp", {}))


def input_path(wildcards):
    """Extracts input path from sample overview."""

    if wildcards.pair not in {"R1", "R2"}:
        raise ValueError("Unexpected value for pair wildcard ({})"
                         .format(wildcards.pair))

    # Lookup sample for given lane/sample ids.
    subset = samples.query('sample == {!r} and lane == {!r}'
                           .format(wildcards.sample, wildcards.lane))

    if len(subset) > 1:
        raise ValueError('Multiple samples found for {}/{}'
                         .format(wildcards.sample, wildcards.lane))
    elif len(subset) == 0:
        raise ValueError('No samples found for {}/{}'
                         .format(wildcards.sample, wildcards.lane))

    # Extract file_path.
    fastq_col = "fastq1" if wildcards.pair == "R1" else "fastq2"
    file_path = subset.iloc[0][fastq_col]

    # Prepend local directory if given.
    input_dir = config["input"].get("dir", None)

    if input_dir is not None:
        file_path = path.join(input_dir, file_path)

    # Wrap remote paths.
    file_path = _wrap_if_remote(file_path)

    return file_path


def _wrap_if_remote(file_path):
    """Wraps remote file paths with remote wrapper."""

    if file_path.startswith("http"):
        file_path = HTTP.remote(file_path)
    elif file_path.startswith("ftp"):
        file_path = FTP.remote(file_path)

    return file_path


rule copy_input:
    input:
        input_path
    output:
        temp("fastq/raw/{sample}.{lane}.{pair}.fastq.gz")
    resources:
        io=1
    shell:
        "cp {input} {output}"
