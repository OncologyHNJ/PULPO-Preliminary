rule prepare_ogm_data:
    output:
        done = f"{logsdir}/DATA/descompressOGM/succesfulldescompresion.txt",
        ogm_dir = directory(expand(f"{resultsdir}/DATA/Patients/{{anonymised}}/OGMdata", anonymised=sample_table['anonymised']))
    run:
        import os
        import shutil

        if config['analysis']['zip']:
            shell("snakemake descompressOGM")
        else:
            for _, row in sample_table.iterrows():
                anon = row['anonymised']
                source = os.path.join(config['input']['bionanodata'], row['bionano'])
                target = f"{resultsdir}/DATA/Patients/{anon}/OGMdata"
                os.makedirs(target, exist_ok=True)

                if os.path.exists(source):
                    for file in os.listdir(source):
                        shutil.copy2(os.path.join(source, file), os.path.join(target, file))
                else:
                    raise FileNotFoundError(f"Bionano data not found: {source}")

            with open(output.done, 'w') as f:
                f.write("OGM data already uncompressed and copied.\n")

