from os import path

import pandas as pd


if config["options"]["pdx"]:

    rule star_fusion_filter_junctions:
        input:
            junctions="star/aligned/{sample}.graft/Chimeric.out.junction",
            bam_files=["star/final/{sample}.bam"],
            bai_indices=["star/final/{sample}.bam.bai"]
        output:
            "star_fusion/junctions/{sample}.out.junction"
        params:
            script=path.join(workflow.basedir, "scripts",
                             "star_fusion_filter_chimeric.py")
        resources:
            memory=5
        conda:
            path.join(workflow.basedir, "envs", "star_fusion_filter.yaml")
        log:
            "logs/star-fusion-filter/{sample}.log"
        shell:
            "python {params.script} --junctions {input.junctions}"
            " --bam_files {input.bam_files} --output {output} 2> {log}"


    rule star_fusion:
        input:
            junctions="star_fusion/junctions/{sample}.out.junction",
            reference=config["references"]["star_fusion"]
        output:
            "star_fusion/output/{sample}/star-fusion.fusion_predictions.tsv"
        params:
            output_dir="star_fusion/output/{sample}"
        conda:
            path.join(workflow.basedir, "envs", "star_fusion.yaml")
        log:
            "logs/star-fusion/{sample}.log"
        shell:
            "STAR-Fusion"
            " --genome_lib_dir {input.reference}"
            " -J {input.junctions}"
            " --output_dir {params.output_dir} 2> {log}"

else:

    rule star_fusion:
        input:
            junctions="star/aligned/{sample}/Chimeric.out.junction",
            reference=config["references"]["star_fusion"]
        output:
            "star_fusion/output/{sample}/star-fusion.fusion_predictions.tsv"
        params:
            output_dir="star_fusion/output/{sample}"
        conda:
            path.join(workflow.basedir, "envs", "star_fusion.yaml")
        log:
            "logs/star-fusion/{sample}.log"
        shell:
            "STAR-Fusion"
            " --genome_lib_dir {input.reference}"
            " -J {input.junctions}"
            " --output_dir {params.output_dir} 2> {log}"


rule star_fusion_merge:
    input:
        expand("star_fusion/output/{sample}/star-fusion.fusion_predictions.tsv",
               sample=get_samples())
    output:
         "star_fusion/merged.txt"
    run:
        def _sample_name(file_path):
            return path.basename(path.dirname(file_path))

        frames = (pd.read_csv(fp, sep='\t')
                    .assign(Sample=_sample_name(fp))
                  for fp in input)

        merged = pd.concat(frames, axis=0, ignore_index=True)
        merged.to_csv(output[0], sep='\t', index=False)
