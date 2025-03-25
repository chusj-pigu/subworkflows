process mosdepth {
    
    container="quay.io/biocontainers/mosdepth:0.3.3--h37c5b7d_2"
    publishDir "${params.out_dir}/reports/mosdepth", mode: 'link', enabled: params.publish, pattern: '*.regions.bed.gz'
    tag "mosdepth $bam.baseName"
    label "mosdepth"

    input:
    tuple val(sample_id), path(bam), path(bai), path(bed), val(flag), val(qual)

    output:
    path "*.dist.txt", emit: dist
    path "*.summary.txt", emit: summary
    path "*.bed.gz", emit: bed, optional: true

    script:
    def bedfile = bed.name != 'NO_BED' ? "-b $bed" : ""
    def threads = task.cpus
    """
    mosdepth -t ${threads} -n -F $flag -Q $qual $bedfile '$sample_id' $bam
    """
}