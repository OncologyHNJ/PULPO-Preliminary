rule sigprofilermatrixgeneratorcnv:
    input:
        sigprofilercnv=f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv"

    output:
        output=directory(f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/"),
        cnvmatrix=f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
        log_file=f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
    params:
        pythondirectory=f"{config['directories']['pythonenvdir']}",
        script=f"{config['directories']['scriptsdir']}/10_Sigprofilermatrixgeneratorcnvs.R",
        log_file = f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log",
    shell:
        """
        (touch {output.log_file}
        Rscript {params.script} {input.sigprofilercnv} {params.pythondirectory} {output.output} {wildcards.anonymised} {output.cnvmatrix})  > {output.log_file} 2>&1 || echo "..." >> {output.log_file}

        """

rule sigprofilerextractorcnv:
    input:
        cnvmatrix=f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",
    output:
        output=directory(f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/Extractor/"),
    params:
        min_signatures="1", # default value
        max_signatures="25", #25,  # default value
        nmf_replicates="500", #100, # default value
        pythondirectory=f"{config['directories']['pythonenvdir']}",
        script=f"{config['directories']['scriptsdir']}/11_Sigprofilerextractorcnvs.R",
        error_log=f"{logsdir}/CNVs/SigProfilerExtractor/Error_log.tsv", # Centralised error file

    shell:
        """
        Rscript {params.script} {input.cnvmatrix} {params.pythondirectory} {output.output} {params.min_signatures} {params.max_signatures} {params.nmf_replicates} {params.error_log} || true
        """
