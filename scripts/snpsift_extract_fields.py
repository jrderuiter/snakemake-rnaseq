"""Helper script for running SnpSift extractFields."""

from snakemake.shell import shell

# Get extra params.
extra = snakemake.params.get("extra")

# Assemble fields.
fields = list(snakemake.params.fields)

if snakemake.params.sample_fields:
    for field in snakemake.params.sample_fields:
        fields += [
            field.replace("<sample>", sample)
            for sample in snakemake.params.samples
        ]

field_expr = " ".join(fields)

# Run command.
shell("SnpSift extractFields {extra} {snakemake.input} {field_expr}"
      " > {snakemake.output}")
