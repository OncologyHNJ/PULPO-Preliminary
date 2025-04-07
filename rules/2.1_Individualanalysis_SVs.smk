rule sigprofilermatrixgenerator:
    input:
        data2 = f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerSVdf.bedpe"
    output:
        output = directory(f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/"),
        data= f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script = f"{config['directories']['scriptsdir']}/5_Sigprofilermatrixgenerator.R",
    log:
        log_file = f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log"
    shell:
        """
        Rscript {params.script} {input.data2} {params.pythondirectory} {output.output} {wildcards.anonymised} &> {log.log_file} || true
        """


rule sigprofilerextractor:
    input:
        data = f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.SV32.matrix.tsv",
    output:
        log_file = f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilerextractor.log",
        output = directory(f"{resultsdir}/SVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/")
    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script = f"{config['directories']['scriptsdir']}/6_Sigprofilerextractor.R",
        minimum_signatures = "1",
        maximum_signatures = "25",
        nmf_replicates = "100",
    log:
        log_file = f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilerextractor.log"
    shell:
        """
        Rscript {params.script} {input.data} {params.pythondirectory} {output.output} {params.minimum_signatures} {params.maximum_signatures} {params.nmf_replicates} #&> {log.log_file}
        """



