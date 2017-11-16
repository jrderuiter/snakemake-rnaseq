Installation
============

If you simply want to use this workflow, download and extract the
`latest release`_. If you intend to modify and further develop this
workflow, fork this repository. Please consider providing any generally
applicable modifications via a pull request.

.. _latest release: https://github.com/jrderuiter/snakemake-rnaseq/releases

To be able to run the workflow, you at least need to have snakemake and pandas
installed. A basic (conda) environment containing these dependencies can be
setup as follows:

.. code:: bash

    conda create -n snakemake snakemake pandas

The various external tools (e.g. bwa, samtools) are managed automatically by
snakemake if the ``--use-conda`` flag is used. Otherwise, these external tools
also need to be installed into the environment or must be available
in ``$PATH``.
