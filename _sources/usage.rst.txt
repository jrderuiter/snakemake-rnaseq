Usage
=====

Running locally
---------------

Once configured, the workflow can be run using snakemake. Often, it is prudent
to first test your configuration by performing a dry-run using::

    snakemake --use-conda -n

If you are satisfied with your configuration, you can execute the workflow
locally on ``$N`` cores using::

    snakemake --use-conda --cores $N

Running on a cluster
--------------------

You can also run the workflow in a cluster environment using::

    snakemake --cluster qsub --jobs 100


Running in a different folder
-----------------------------

If you want to run the workflow in another directory to avoid
modifying files in the workflow, you can run snakemake in a different work
directory as follows::

    snakemake --directory ~/scratch

This assumes that the command ifself is run in the workflow directory,
otherwise snakemake won't find the Snakefile. The command can also be run
elsewhere as follows::

    snakemake -s ~/path/to/workflow/Snakefile --directory ~/scratch

Note that in both cases, ``~/scratch`` should contain the appropriate
``config.yaml`` and ``sample.tsv`` files, as snakemake searches for these
files in the work directory.

See the `Snakemake documentation`_ for further details on snakemake options.


.. _Snakemake documentation: https://snakemake.readthedocs.io
