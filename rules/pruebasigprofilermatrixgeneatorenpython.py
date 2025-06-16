#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 29 16:21:14 2025

@author: user
"""
import subprocess
env_name = "PULPO"
subprocess.run(f"conda init", shell=True, executable="/bin/bash")
subprocess.run(f"conda activate {env_name} && python pruebasigprofilermatrixgeeratorenpython.py", shell=True, executable="/bin/bash")



import pandas as pd
from SigProfilerMatrixGenerator.scripts import SigProfilerMatrixGeneratorFunc as matGen

df = pd.read_csv("/home/user/MARTA/PULPO_ejecutadoprueba/results/Patients/Patient-71/SigProfiler/data/SigProfilerCNVdf.tsv", sep="\t")  # Usa el separador correcto

print(df.shape)
print(df.head())
print(df.isnull().sum())


matrices = matGen.SigProfilerMatrixGeneratorFunc("PCAWG", "GRCh38", "/home/user/MARTA/PULPO_ejecutadoprueba/results/Patients/Patient-71/SigProfiler/data/SigProfilerCNVdf.tsv",plot=True, exome=False, bed_file=None, chrom_based=False, tsb_stat=False, seqInfo=False, cushion=100)
