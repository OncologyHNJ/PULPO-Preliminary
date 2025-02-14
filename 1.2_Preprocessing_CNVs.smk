rule bionanotosigprofilercnv:
    input:
        bionanodirectory = f"{resultsdir}/Patients/{{anonymised}}/OGMdata",
       # bionanodirectory = "/home/user/MARTA/PULPO_RevisadoBionano/results/Patients/Patient-32/OGMdata"
       # bionanodirectory = f"{resultsdir}/Patients/{{anonymised}}/OGMdata",
        #"/home/user/MARTA/PULPO_RevisadoBionano/results/Patients/Patient-16/OGMdata"
    output:
        outputdirectoryfile = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv"
       # mkdir = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/",
       # outputdirectoryfile = "/home/user/MARTA/PULPO_RevisadoBionano/results/Patients/Patient-32/SigProfiler/data/SigProfilerCNVdf.tsv"
    log:
       # log_file = f"{logsdir}/SigProfiler/Patients/{{anonymised}}/bionanotosigprofilercnv.log"
        log_file = f"{logsdir}/SigProfiler/Patients/{{anonymised}}/bionanotosigprofilercnv.log"
    params:
        mkdir = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/",
        script = f"{config['directories']['scriptsdir']}/9.CNVTOFORMAT.R",
    shell:
        """
        Rscript {params.script} {input.bionanodirectory} {output.outputdirectoryfile} {wildcards.anonymised} #&> {log.log_file}
        """


