
rule mergepatients:
    input:
        log_file = expand(f"{logsdir}/SVs/Patients/{{anonymised}}/SigProfiler/sigprofilermatrix.log", anonymised=sample_table['anonymised'])
    output:
        outputcohort = f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
    params:
        directorypatients = f"{resultsdir}/SVs/Patients",
        script = f"{config['directories']['scriptsdir']}/7_Mergecohortsvs.R",
    log:
        log_file = f"{logsdir}/SVs/Cohort/mergepatients/mergepatients.log"
    shell:
        """
        Rscript {params.script} {params.directorypatients} {output.outputcohort} &> {log.log_file} || true
        """

rule sigprofilerextractorcohort:
    input:
        data = f"{resultsdir}/SVs/Cohort/Cohort.SV32.matrix.tsv",
    output:
        output = directory(f"{resultsdir}/SVs/Cohort/SigProfiler/")

    params:
        pythondirectory = f"{config['directories']['pythonenvdir']}",
        script= f"{config['directories']['scriptsdir']}/8_Sigprofilerextractorcohort.R",
        minimum_signatures = "1",
        maximum_signatures = "25",
        nmf_replicates = "500"
    log:
        log_file = f"{logsdir}/SVs/Cohort/SigProfiler/sigprofilerextractorcohort.log"
    shell:
        """
        Rscript {params.script} {input.data} {params.pythondirectory} {output.output} {params.minimum_signatures} {params.maximum_signatures} {params.nmf_replicates} &> {log.log_file} || true 
        echo "The PULPO v.1.1 SVs analysis has been finished"
        """
