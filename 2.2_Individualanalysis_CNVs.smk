
rule sigprofilermatrixgeneratorcnv:
    input:
        sigprofilercnv = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv"

    output:
        output = directory(f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/MatrixGenerator/"),
        cnvmatrix = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script = f"{config['directories']['scriptsdir']}/10_Sigprofilermatrixgeneratorcnvs.R",
        log_file = f"{logsdir}/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
     #   error_file = f"{logsdir}/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log"
    shell:
        """
        Rscript {params.script} {input.sigprofilercnv} {params.pythondirectory} {output.output} {wildcards.anonymised} {output.cnvmatrix}  || true &> {params.log_file}
        """



rule sigprofilerextractorcnv:
    input:
        cnvmatrix = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
    output:
        output = directory(f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/results/CNVs/Extractor/")
    params:
        min_signatures = "1",  # default value
        max_signatures = "25", #25,  # default value
        nmf_replicates = "100", #100, # default value
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script = f"{config['directories']['scriptsdir']}/11_Sigprofilerextractorcnvs.R",
        error_log = f"{logsdir}/SigProfilerExtractor/Error_log.tsv",  # Centralised error file
      #  log = f"{logsdir}/SigProfilerExtractor/logtsv.tsv",
    shell:
        """
        Rscript {params.script} {input.cnvmatrix} {params.pythondirectory} {output.output} {params.min_signatures} {params.max_signatures} {params.nmf_replicates} {params.error_log} || true      
        """

