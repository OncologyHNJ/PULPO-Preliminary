
rule mergepatientcnvs:
    input:
        directorypatients = f"{resultsdir}/Patients",
    output:
        outputcohort =  f"{resultsdir}/Cohort/CNVs/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
    params:
        script = f"{config['directories']['scriptsdir']}/12_Mergecohortcnvs.R"
    log:
        log_file = f"{logsdir}/Cohort/CNVs/mergepatients/mergepatientscnvs.log"
    shell:
        """
        touch {output.outputcohort}
        Rscript {params.script} {input.directorypatients} {output.outputcohort} &> {log.log_file} || true
        """

rule sigprofilerextractorcnvscohort:
    input:
        cnvmatrix =  f"{resultsdir}/Cohort/CNVs/Cohort.CNV48.matrix.tsv",
    output:
        output= directory(f"{resultsdir}/Cohort/CNVs/SigProfiler/Extractor/"),
    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script =  f"{config['directories']['scriptsdir']}/13_Sigprofilerextractorcnvscohort.R",
        min_signatures = "1",# default value
        max_signatures = "25",  # default value
        nmf_replicates = "100", # default value
    log:
        log_file= f"{logsdir}/Cohort/CNVs/SigProfiler/sigprofilercnvextractorcnvscohort.log"
    shell:
        """
        Rscript {params.script} {input.cnvmatrix} {params.pythondirectory} {output.output} {params.min_signatures} {params.max_signatures} {params.nmf_replicates} &> {log.log_file} || true
        """

