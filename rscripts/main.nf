process clean_countmx {
    publishDir "${params.out_dir}/reports", mode: 'link', enabled: params.publish
    container 'rocker/tidyverse:latest'

    input:
    path tab

    output:
    path "readCounts_summary.csv"

    script:
    """
    clean_countmx.R
    """
}

process clean_vcf {
    publishDir "${params.out_dir}", mode: params.publish_mode
    container 'rocker/tidyverse:latest'
    tag "$type"
    label "rscript"

    input:
    tuple val(type), path(table), path(bed_genes), path(cancer_ex)

    output:
    path "*.tsv", optional:true
    
    when:
    table.size() > 0

    script:
    """
    vcf_arrange.R $table $bed_genes $cancer_ex
    """
}

process coverage_as {
    publishDir "${params.out_dir}/reports", mode: 'link'
    container 'ghcr.io/chusj-pigu/tidyverse:latest'

    input:
    path(bed_nofilter)
    path(bed_primary)
    path(bed_mapq60)
    val(background_cov)
    path(low_fidelity_list)
    
    output:
    path "*.pdf"

    script:
    """
    coverage_plot.R \\
        -n ${bed_nofilter} \\
        -p ${bed_primary} \\
        -u ${bed_mapq60} \\
        -b ${background_cov} \\
        -l ${low_fidelity_list} \\
        -o ${prefix}_coverage_mapq.pdf
    """
    
}