process RUN_METAPHLAN {
    tag "$meta.id"
    label 'process_high'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/metaphlan:3.0.13--pyhb7b1952_0' :
        'quay.io/biocontainers/metaphlan:3.0.13--pyhb7b1952_0' }"

    publishDir "${params.outdir}/metaphlan", mode: 'copy', overwrite: true, pattern: "*_metaphlan.txt"

    input:
    tuple val(meta), path(input)
    path metaphlan_db

    output:
    tuple val(meta), path("*_metaphlan.txt"), emit: metaphlan_profile
    path "versions.yml",                      emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_type = ("$input".endsWith(".fastq.gz") || "$input".endsWith(".fq.gz")) ? "--input_type fastq" : 
                     ("$input".contains(".fasta")) ? "--input_type fasta" : 
                     ("$input".endsWith(".bowtie2out.txt")) ? "--input_type bowtie2out" : "--input_type sam"
    def input_data = ("$input_type".contains("fastq")) && !meta.single_end ? "${input[0]},${input[1]}" : "$input"
    def bowtie2_out = "$input_type" == "--input_type bowtie2out" || "$input_type" == "--input_type sam" ? '' : "--bowtie2out ${prefix}.bowtie2out.txt"

    """
    metaphlan \\
        --nproc $task.cpus \\
        -t rel_ab_w_read_stats \\
        $input_type \\
        $input_data \\
        $bowtie2_out \\
        --index mpa_v30_CHOCOPhlAn_201901 \\
        --bowtie2db ./$metaphlan_db \\
        --add_viruses \\
        --unknown_estimation \\
        --force \\
        --no_map \\
        --output_file ${prefix}_metaphlan.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}
