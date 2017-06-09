
rule multiqc:
    input:
        expand('counts/{sample}.txt', sample=samples)
    output:
        'multiqc_report.html'
    shell:
        'multiqc .'
