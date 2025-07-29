process RUN_HUMANN {
    tag "$meta.id"
    label 'process_high'
    
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/humann:3.7--pyh7cba7a3_0' :
        'quay.io/biocontainers/humann:3.7--pyh7cba7a3_0' }"

    publishDir "${params.outdir}/humann/genefamilies",  mode: 'copy', overwrite: true, pattern: "*_genefamilies.tsv"
    publishDir "${params.outdir}/humann/pathabundance", mode: 'copy', overwrite: true, pattern: "*_pathabundance.tsv"
    publishDir "${params.outdir}/humann/pathcoverage",  mode: 'copy', overwrite: true, pattern: "*_pathcoverage.tsv"

    input:
    tuple val(meta), path(input), path(metaphlan_profile)
    path nucleotide_db
    path protein_db

    output:
    tuple val(meta), path("*_genefamilies.tsv"),  emit: genefamilies
    tuple val(meta), path("*_pathabundance.tsv"), emit: pathabundance
    tuple val(meta), path("*_pathcoverage.tsv"),  emit: pathcoverage
    tuple val(meta), path("*.log"),               emit: log
    path "versions.yml",                          emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_data = !meta.single_end ? "${input[0]} ${input[1]}" : "$input"
    def merged_input = !meta.single_end ? "${prefix}_merged.fastq" : "${prefix}_input.fastq"

    """
    humann_config > log.txt
    humann_config \\
        --update database_folders nucleotide $nucleotide_db

    humann_config \\
        --update database_folders protein $protein_db

    # Prepare input files
    if [ "${meta.single_end}" = "true" ]; then
        echo "Single-end input processing"
        if [[ "${input}" == *.gz ]]; then
            zcat "${input}" > "${prefix}_input.fastq"
        else
            cp "${input}" "${prefix}_input.fastq"
        fi
        input_file="${prefix}_input.fastq"
    else
        echo "Paired-end detected, merging reads"
        if [[ "${input[0]}" == *.gz ]]; then
            zcat "${input[0]}" > temp_read1.fastq
        else
            cp "${input[0]}" temp_read1.fastq
        fi
        if [[ "${input[1]}" == *.gz ]]; then
            zcat "${input[1]}" > temp_read2.fastq
        else
            cp "${input[1]}" temp_read2.fastq
        fi
        cat temp_read1.fastq temp_read2.fastq > "${prefix}_merged.fastq"
        input_file="${prefix}_merged.fastq"
    fi

    humann \\
        --input \$input_file \\
        --input-format fastq \\
        --taxonomic-profile ${metaphlan_profile} \\
        --o-log "${prefix}.log" \\
        --output . \\
        --threads ${task.cpus}

    # Rename output files to include prefix
    mv *_genefamilies.tsv  ${prefix}_genefamilies.tsv
    mv *_pathabundance.tsv ${prefix}_pathabundance.tsv
    mv *_pathcoverage.tsv  ${prefix}_pathcoverage.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        humann: \$(humann --version 2>&1 | awk '{print \$2}')
    END_VERSIONS
    """
}
