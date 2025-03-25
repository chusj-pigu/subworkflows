process nanoplot {
    
    container="nanozoo/nanoplot:1.42.0--547049c"
    tag "nanoplot $sample_id"
    
    input: 
    tuple val(sample_id), path(reads)

    output: 
    path "*"

    script:
    def type = (params.skip_basecall || params.demux != null) ? "--fastq" : "--ubam"
    """
    NanoPlot -t $task.cpus -p $sample_id --minqual 10 --huge $type $reads
    """
}