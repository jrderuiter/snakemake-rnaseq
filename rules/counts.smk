
rule feature_counts:
    input:
        bam='star/{sample}/Aligned.sortedByCoord.out.bam',
        bai='star/{sample}/Aligned.sortedByCoord.out.bam.bai'
    output:
        'counts/{sample}.txt'
    params:
        annotation=config['feature_counts']['annotation'],
        extra=config['feature_counts']['extra']
    threads: 2
    log:
        'logs/feature_counts/{sample}.txt'
    shell:
        'featureCounts {params.extra} -a {params.annotation}'
        ' -o {output} -T {threads} {input.bam} 2> {log}'

rule merge_counts:
    input:
        expand('counts/{sample}.txt', sample=samples)
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
