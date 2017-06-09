
rule multiqc:
    input:
        expand('counts/{sample}.txt', sample=samples),
        expand('fastqc/{sample}.{pair}_fastqc.zip', sample=samples, pair=['R1'])
    output:
        'multiqc_report.html'
    shell:
        'multiqc --force .'
