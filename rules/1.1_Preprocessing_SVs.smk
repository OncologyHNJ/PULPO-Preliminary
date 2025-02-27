rule check_svs:
    input:
        input = f"{resultsdir}/Patients/{{anonymised}}/OGMdata/"
    output:
        output = f"{resultsdir}/Patients/{{anonymised}}/OGMdata/check_svs_done.txt"
    params:
        script = f"{config['directories']['scriptsdir']}/CheckfilesSV.R",
        general_log = f"{resultsdir}/Checkpoints/check_svs_all.txt"
    shell:
        """
        mkdir -p {resultsdir}/Checkpoints
        echo "Processing sample {wildcards.anonymised}..." >> {params.general_log}
        if ! Rscript {params.script} {wildcards.anonymised} {input.input} >> {params.general_log} 2>&1; then
            echo "Sample {wildcards.anonymised} failed. See {input.input}/check_svs_error.txt" >> {params.general_log}
            exit 1
        fi
        echo "Finished processing sample {wildcards.anonymised}" >> {params.general_log}
        touch {output.output}
        """

rule formatbedpe:
    input:
        bionanodirectory = directory(f"{resultsdir}/Patients/{{anonymised}}/"),
    output:
        bedpedirectory= f"{resultsdir}/Patients/{{anonymised}}/OGMdata/{{anonymised}}.bedpe",
    log:
        log_file = f"{logsdir}/Patients/{{anonymised}}/formatbedpe/formatbedpe.log",
    params:
        script = f"{config['directories']['scriptsdir']}/4_FORMATBEDPE.R"
    shell:
        """
        Rscript {params.script} {input.bionanodirectory} &> {log.log_file} 
        """

rule bedpetosigprofiler:
    input:
        bedpedirectory = f"{resultsdir}/Patients/{{anonymised}}/OGMdata/{{anonymised}}.bedpe",
    output:
        outputdirectoryfile = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
    params:
        inputdata = directory(f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/"),
        script = f"{config['directories']['scriptsdir']}/4.2_FORMATBEDPETOSIGPROFILER.R",
    log:
        log_file = f"{logsdir}/Patients/{{anonymised}}/SigProfiler/bedpetosigprofilermatrix.log"
    shell:
        """
        Rscript {params.script} {input.bedpedirectory} {wildcards.anonymised} {params.inputdata} {output.outputdirectoryfile} &> {log.log_file}
        """
