process sam_sort {

    publishDir "${params.out_dir}/alignments", mode: 'link', enabled: params.publish
    label "sam_big"
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    tag "sam_sort $sample_id"

    input: 
    tuple val(sample_id), path(sam)

    output:
    tuple val(sample_id), path("${sam.baseName}.bam"), path("${sam.baseName}.bam.bai")
    
    script:
    """
    samtools view --no-PG -@ $params.threads -Sb $sam \
    | samtools sort -@ $params.threads --write-index -o ${sam.baseName}.bam##idx##${sam.baseName}.bam.bai
    """
}

process ubam_to_fastq {

    publishDir "${params.out_dir}/reads", mode: 'link', enabled: params.publish
    label "sam_long"
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    tag "bam-fastq $ubam.baseName"

    input:
    tuple val(sample_id), path(ubam)

    output:
    tuple val(sample_id), path("${ubam.baseName}.fq.gz")

    script:
    def mod = params.no_mod ? "" : "-T '*'" 
    """
    samtools fastq $mod -@ $params.threads $ubam > ${ubam.baseName}.fq.gz
    """
}

process qs_filter {
    
    label "sam_sm"
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    tag "qc filter $sample_id"

    input:
    tuple val(sample_id), path(ubam)

    output:
    tuple val(sample_id), path("${sample_id}_pass.bam"), emit: ubam_pass
    tuple val(sample_id), path("${sample_id}_fail.bam"), emit: ubam_fail

    script:
    """
    samtools view --no-PG -@ $params.threads -e '[qs] >=$params.minqs' -b $ubam --output ${sample_id}_pass.bam --unoutput ${sample_id}_fail.bam
    """
}

process mergeChunks {
    
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    tag "merge $chunk"
    label "sam_mid"
    debug true
    executor 'slurm'
    array 22
    
    input:
    tuple val(chunk), path(bam)
    
    output:
    path "${chunk}.bam"

    script:
    """
    samtools merge -@ ${params.threads} --no-PG "${chunk}.bam" $bam
    """
}

process mergeFinal {
    
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    publishDir "${params.out_dir}/alignments", mode: 'link', enabled: params.publish
    label "sam_big"

    input:
    path merged_bams

    output:
    tuple path("${params.sample_id}.hg38.bam"), path("${params.sample_id}.hg38.bam.bai")

    script:
    """
    samtools merge -@ $params.threads $merged_bams | samtools sort -@ $params.threads --write-index -o ${params.sample_id}.hg38.bam##idx##${params.sample_id}.h38.bam.bai
    """
}

process separate_panel {
    
    container="ghcr.io/bwbioinfo/samtools-docker-cwl:e80764711a121872e9ea35d90229cec6dd6d8dec"
    label "sam_mid"

    input:
    path bam
    path bed

    output:
    tuple path("${bam.baseName}_panel.bam"), path("${bam.baseName}_panel.bam.bai"), emit: panel
    tuple path("${bam.baseName}_bg.bam"), path("${bam.baseName}_bg.bam.bai"), emit: bg
    
    script:
    """
    samtools view -b -@ $params.threads -x MM,ML -L $bed --write-index -o ${bam.baseName}_panel.bam##idx##${bam.baseName}_panel.bam.bai -U ${bam.baseName}_bg.bam##idx##${bam.baseName}_bg.bam.bai $bam
    """
}
