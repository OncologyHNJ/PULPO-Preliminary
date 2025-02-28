
rule mergepatients:
    input:
        directorypatients = f"{resultsdir}/Patients/",
    output:
        outputcohort = f"{resultsdir}/Cohort/SVs/Cohort.SV32.matrix.tsv",
    params:
        script = f"{config['directories']['scriptsdir']}/7_Mergecohortsvs.R",
    log:
        log_file = f"{logsdir}/Cohort/SVs/mergepatients/mergepatients.log"
    shell:
        """
        Rscript {params.script} {input.directorypatients} {output.outputcohort} &> {log.log_file} || true
        """

rule sigprofilerextractorcohort:
    input:
        data = f"{resultsdir}/Cohort/SVs/Cohort.SV32.matrix.tsv",
    output:
        output = directory(f"{resultsdir}/Cohort/SVs/SigProfiler/")

    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script= f"{config['directories']['scriptsdir']}/8_Sigprofilerextractorcohort.R",
        minimum_signatures = "1",
        maximum_signatures = "25",
        nmf_replicates = "100"
    log:
        log_file = f"{logsdir}/Cohort/SigProfiler/SVs/sigprofilerextractorcohort.log"
    shell:
        """
        Rscript {params.script} {input.data} {params.pythondirectory} {output.output} {params.minimum_signatures} {params.maximum_signatures} {params.nmf_replicates} &> {log.log_file} || true 
        """
