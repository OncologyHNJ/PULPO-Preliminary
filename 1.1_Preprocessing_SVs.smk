rule check_svs:
    input:
        done = f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
        OGM = f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata",

    output:
        output= f"{resultsdir}/SVs/Patients/{{anonymised}}/Check/check_svs_done.txt",
    params:
        input = f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",
        script = f"{config['directories']['scriptsdir']}/CheckfilesSV.R",
        general_log = f"{resultsdir}/SVs/Checkpoints/check_svs_all.txt"
    shell:
        """
        mkdir -p {resultsdir}/SVs/Checkpoints
        echo "Processing sample {wildcards.anonymised}..." >> {params.general_log}
        if ! Rscript {params.script} {wildcards.anonymised} {params.input} >> {params.general_log} 2>&1; then
            echo "Sample {wildcards.anonymised} failed. See {params.input}/check_svs_error.txt" >> {params.general_log}
            exit 1
        fi
        echo "Finished processing sample {wildcards.anonymised}" >> {params.general_log}
        touch {output.output}
        """

rule formatbedpe:
    input:
        output= f"{resultsdir}/SVs/Patients/{{anonymised}}/Check/check_svs_done.txt",
    output:
        output = f"{resultsdir}/SVs/Patients/{{anonymised}}/ProcessData/{{anonymised}}.bedpe",
    log:
        log_file = f"{logsdir}/SVs/Patients/{{anonymised}}/formatbedpe/formatbedpe.log",
    params:
        bionanodirectory = f"{resultsdir}/DATA/Patients/",
        script = f"{config['directories']['scriptsdir']}/4_FORMATBEDPE.R",
        outputdirbaseSVs = f"{resultsdir}/SVs/Patients"
    shell:
        """ 
        Rscript {params.script} {params.bionanodirectory} {params.outputdirbaseSVs} &> {log.log_file} 
        """

rule bedpetosigprofiler:
    input:
        bedpedirectory = f"{resultsdir}/SVs/Patients/{{anonymised}}/ProcessData/{{anonymised}}.bedpe",
    output:
        outputdirectoryfile = f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
    params:
        inputdata = directory(f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/"),
        script = f"{config['directories']['scriptsdir']}/4.2_FORMATBEDPETOSIGPROFILER.R",
    log:
        log_file = f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/bedpetosigprofilermatrix.log"
    shell:
        """
        Rscript {params.script} {input.bedpedirectory} {wildcards.anonymised} {params.inputdata} {output.outputdirectoryfile} &> {log.log_file}
        """

