rule feature_counts:
    input:
        bam='bam/merged/{sample}.bam',
        bai='bam/merged/{sample}.bam.bai',
    output:
        counts='counts/{sample}.txt',
        summary='qc/feature_counts/{sample}.txt'
    params:
        annotation=config['feature_counts']['annotation'],
        extra=config['feature_counts']['extra']
    threads:
        config['feature_counts']['threads']
    log:
        'logs/feature_counts/{sample}.txt'
    wrapper:
        'file://' + path.join(workflow.basedir, 'wrappers/subread/feature_counts')


rule merge_counts:
    input:
        expand('counts/{sample}.txt', sample=get_samples())
    output:
        'merged.txt'
    run:
        def merge_counts(file_paths):
            frames = (pd.read_csv(fp, sep='\t', skiprows=1,
                                  index_col=list(range(6)))
                      for fp in file_paths)

            return pd.concat(frames, axis=1)

        merged = merge_counts(input)
        merged.to_csv(output[0], sep='\t', index=True)
