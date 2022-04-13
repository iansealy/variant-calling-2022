#!/usr/bin/env bash
#$ -cwd
#$ -pe smp 1
#$ -l h_rt=240:0:0
#$ -l h_vmem=10G
#$ -o run_snakemake.o
#$ -e run_snakemake.e

module purge
module load Snakemake/7.3.1
module load pandas/1.4.2

snakemake --use-envmodules --cores 1
