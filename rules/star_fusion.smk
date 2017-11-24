from os import path


if config["options"]["pdx"]:

    rule star_fusion_filter_junctions:
        input:
            junctions="star/aligned/{sample}.graft/Chimeric.out.junction",
            bam_files=["star/final/{sample}.bam"]
        output:
            "star_fusion/junctions/{sample}.out.junction"
        params:
            script=path.join(workflow.basedir, "scripts",
                             "star_fusion_filter_chimeric.py")
        resources:
            memory=5
        shell:
            "python {params.script} --junctions {input.junctions}"
            " --bam_files {input.bam_files} --output {output}"


    rule star_fusion:
        input:
            junctions="star_fusion/junctions/{sample}.out.junction",
            reference=config["references"]["star_fusion"]
        output:
            "star_fusion/output/{sample}/star-fusion.fusion_predictions.tsv"
        params:
            output_dir="star_fusion/{sample}"
        shell:
            "STAR-Fusion"
            " --genome_lib_dir {input.reference}"
            " -J {input.junctions}"
            " --output_dir {params.output_dir}"

else:

    rule star_fusion:
        input:
            junctions="star/aligned/{sample}/Chimeric.out.junction",
            reference=config["references"]["star_fusion"]
        output:
            "star_fusion/output/{sample}/star-fusion.fusion_predictions.tsv"
        params:
            output_dir="star_fusion/{sample}"
        shell:
            "STAR-Fusion"
            " --genome_lib_dir {input.reference}"
            " -J {input.junctions}"
            " --output_dir {params.output_dir}"
