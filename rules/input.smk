from os import path

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider


HTTP = HTTPRemoteProvider()
FTP = FTPRemoteProvider(**config["input"].get("ftp", {}))


def input_path(wildcards):
    """Extracts input path from sample overview."""

    # Lookup file path for given unit/pair.
    if wildcards.pair == "R1":
        pair_index = 0
    elif wildcards.pair == "R2":
        pair_index = 1
    else:
        raise ValueError("Unexpected value for pair wildcard ({})"
                         .format(wildcards.pair))

    file_path = config["units"][wildcards.unit][pair_index]

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
        temp("fastq/raw/{unit}.{pair}.fastq.gz")
    resources:
        io=1
    shell:
        "cp {input} {output}"
