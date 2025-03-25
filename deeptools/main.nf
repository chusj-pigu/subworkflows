process multiBamSummary {
    
    container="ghcr.io/bwbioinfo/deeptools-docker-cwl:cae8e2f8bd839f15d37e42b3bc41e3dc69f9fe15"
    label "deeptools"
    tag "multibam $fasta"
    publishDir "${params.out_dir}/reports", mode: 'link', enabled: params.publish

    input:
    tuple val(fasta), path(bam), path(bai)

    output:
    tuple path("${fasta}_readCounts.npz"), path("${fasta}_readCounts.tab")

    script:
    """
    multiBamSummary bins --binSize 50 -b $bam --minMappingQuality 30 -out ${fasta}_readCounts.npz --outRawCounts ${fasta}_readCounts.tab
    """
}

process bamCoverage {

    container="ghcr.io/bwbioinfo/deeptools-docker-cwl:cae8e2f8bd839f15d37e42b3bc41e3dc69f9fe15"
    label "deeptools"
    tag "bigwig"
    publishDir "${params.out_dir}/alignments", mode: 'link'

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    path "${bam.baseName}.bigwig"

    script:
    """
    bamCoverage -b $bam -o ${bam.baseName}.bigwig -of "bigwig"
    """
}