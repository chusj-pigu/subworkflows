process gatk_table {
    container="broadinstitute/gatk"
    tag "$type"

    input:
    tuple val(type), path(vcf), val(field)

    output:
    tuple val(type), path("${vcf.baseName}.table")

    script:
    """
    gatk VariantsToTable -V $vcf -F ID -F CHROM -F POS -F REF -F ALT -F QUAL -F FILTER $field -O ${vcf.baseName}.table --show-filtered
    """
}