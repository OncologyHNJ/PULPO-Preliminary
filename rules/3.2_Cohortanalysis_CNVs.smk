
rule mergepatientcnvs:
    input:
        cnvmatrix = expand(f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/results/MatrixGenerator/{{anonymised}}.CNV48.matrix.tsv",anonymised=sample_table['anonymised']),
        log_file = expand(f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/sigprofilercnvmatrixgenerator.log", anonymised=sample_table['anonymised']),
    output:
        outputcohort =  f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
    params:
        directorypatients = f"{resultsdir}/CNVs/Patients",
        script = f"{config['directories']['scriptsdir']}/12_Mergecohortcnvs.R",

    log:
        log_file = f"{logsdir}/CNVs/Cohort/mergepatients/mergepatientscnvs.log"
    shell:
        """
        touch {output.outputcohort}
        Rscript {params.script} {params.directorypatients} {output.outputcohort} &> {log.log_file} || true
        """

rule sigprofilerextractorcnvscohort:
    input:
        cnvmatrix =  f"{resultsdir}/CNVs/Cohort/SigProfiler/MatrixGenerator/Cohort.CNV48.matrix.tsv",
    output:
        output= directory(f"{resultsdir}/CNVs/Cohort/SigProfiler/Extractor/"),
    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script =  f"{config['directories']['scriptsdir']}/13_Sigprofilerextractorcnvscohort.R",
        min_signatures = "1",# default value
        max_signatures = "25",  # default value
        nmf_replicates = "500", # default value
    log:
        log_file= f"{logsdir}/CNVs/Cohort/SigProfiler/sigprofilercnvextractorcnvscohort.log"
    shell:
        """
        Rscript {params.script} {input.cnvmatrix} {params.pythondirectory} {output.output} {params.min_signatures} {params.max_signatures} {params.nmf_replicates} &> {log.log_file} || true
        echo "The PULPO v.1.1 CNVs-cohort analysis has been finished"
        """

