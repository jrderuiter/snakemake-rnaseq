from os import path

from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider


input_config = config["input"] or {}

HTTP = HTTPRemoteProvider()
FTP = FTPRemoteProvider(**input_config.get("ftp", {}))


def input_path(wildcards):
    """Extracts input path from sample overview."""

    if wildcards.pair not in {"R1", "R2"}:
        raise ValueError("Unexpected value for pair wildcard ({})"
                         .format(wildcards.pair))

    # Lookup file path.
    key = (wildcards.sample, wildcards.lane)
    fastq = "fastq1" if wildcards.pair == "R1" else "fastq2"
    file_path = samples.set_index(["sample", "lane"]).loc[key, fastq]

    # Wrap remote HTTP/FTP path.
    if file_path.startswith("http"):
        file_path = HTTP.remote(file_path)
    elif file_path.startswith("ftp"):
        # Wrap remote HTTP path.
        file_path = FTP.remote(file_path)
    elif "dir" in input_config:
        # Prepend local dir path for local files (if given).
        file_path = path.join(input_config["dir"], file_path)

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
