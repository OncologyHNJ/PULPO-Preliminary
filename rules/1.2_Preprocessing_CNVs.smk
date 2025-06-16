rule check_cnvs:
    input:
        done = rules.prepare_ogm_data.output.done,
        OGM = expand(f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata", anonymised=sample_table['anonymised'])

    output:
        output= f"{resultsdir}/CNVs/Patients/{{anonymised}}/Check/check_cnvs_done.txt"

    params:
        script = f"{config['directories']['scriptsdir']}/CheckfilesCNVs.R",
        log= f"{resultsdir}/CNVs/Checkpoints/check_cnvs_all.txt",
        input = f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",

    shell:
        """
        [ ! -d "{resultsdir}/CNVs/Checkpoints" ] && mkdir -p "{resultsdir}/CNVs/Checkpoints"
        echo "Processing sample {wildcards.anonymised}..." >> {params.log}
        Rscript {params.script} {wildcards.anonymised} {params.input} >> {params.log} 2>&1
        echo "Finished processing sample {wildcards.anonymised}" >> {params.log}
        touch {output.output}
        """


rule bionanotosigprofilercnv:
    input:
        output = f"{resultsdir}/CNVs/Patients/{{anonymised}}/Check/check_cnvs_done.txt",
    output:
        outputdirectoryfile = f"{resultsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/data/SigProfilerCNVdf.tsv"
    log:
        log_file = f"{logsdir}/CNVs/Patients/{{anonymised}}/SigProfiler/bionanotosigprofilercnv.log"
    params:
        mkdir = f"{resultsdir}/Patients/{{anonymised}}/SigProfiler/data/",
        script = f"{config['directories']['scriptsdir']}/9.CNVTOFORMAT.R",
        bionanodirectory= f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata/",
    shell:
        """
        Rscript {params.script} {params.bionanodirectory} {output.outputdirectoryfile} {wildcards.anonymised} #&> {log.log_file}
        """


