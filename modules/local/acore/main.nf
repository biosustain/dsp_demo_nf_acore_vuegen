process ACORE {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    input:
        path input_csv
        path nb

    output:
    path "analysis.ipynb", emit: nb
    path "report_files", emit: report_files
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    papermill \\
        $args \\
        ${nb} \\
        analysis.ipynb \\
        -p file_in ${input_csv}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        acore: \$(python -c "import acore; print(acore.__version__)")
        ipykernel: \$(python -c "import ipykernel; print(ipykernel.__version__)")
        papermill: \$(papermill --version | cut -f1 -d' ')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    echo $args
    
    touch ${nb}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        acore: \$(python -c "import acore; print(acore.__version__)")
    END_VERSIONS
    """
}
