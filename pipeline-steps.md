# Pipeline Steps

Test data:

```
ERR925008	SAMEA2804475	ERS561394	SL7_03_G6-sc-2135576	ftp.sra.ebi.ac.uk/vol1/fastq/ERR925/ERR925008/ERR925008_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR925/ERR925008/ERR925008_2.fastq.gz	541538df7247ac37daca65503e5579e0;859e12e08c53ef75e84ae98fff51ecdb	333167061;334271734
```

- ERR925008 = accession for sequencing run
- SAMEA2804475 = sample accession
- ERS561394 = sample accession
- SL7_03_G6-sc-2135576 = name of the sample

Always name things by the sample accession, not the real name; so we'll use ERS561394

```
mkdir -p /data/scratch/bty107/variant-calling-2022/ERS561394
cd /data/scratch/bty107/variant-calling-2022/ERS561394
```

## 1: Download FASTQ

```
wget -q http://ftp.sra.ebi.ac.uk/vol1/fastq/ERR925/ERR925008/ERR925008_1.fastq.gz
wget -q http://ftp.sra.ebi.ac.uk/vol1/fastq/ERR925/ERR925008/ERR925008_2.fastq.gz
```

## 2: Checksum FASTQ

```
md5sum ERR925008_*
541538df7247ac37daca65503e5579e0  ERR925008_1.fastq.gz
859e12e08c53ef75e84ae98fff51ecdb  ERR925008_2.fastq.gz
```

## 3: Download reference genome

```
mkdir -p /data/scratch/bty107/variant-calling-2022/ref
cd /data/scratch/bty107/variant-calling-2022/ref
wget -q http://ftp.ensembl.org/pub/release-105/fasta/danio_rerio/dna/Danio_rerio.GRCz11.dna_sm.primary_assembly.fa.gz
gunzip Danio_rerio.GRCz11.dna_sm.primary_assembly.fa.gz 
```

## 4: Index reference genome with BWA

Make a script for indexing:

```
nano index.sh
```

index.sh will contain:

```
#!/usr/bin/env bash

module load BWA/0.7.17
bwa index Danio_rerio.GRCz11.dna_sm.primary_assembly.fa
```

Make script executable:

```
chmod +x index.sh
```

Submit a job on the cluster:

```
qsub -cwd -pe smp 1 -l h_rt=1:0:0 -l h_vmem=10G -o index.o -e index.e index.sh
```

## 5: Map reads to reference genome with BWA

First try whole genome with all the reads

If that takes too long then try batching the reads

Because of the length of the reads, we're going to use bwa aln/sampe (rather than bwa mem)

End result will be a BAM file

## 6: Mark duplicates in the BAM file

Could use GATK, but it's a very fussy tools and requires things like all the chromosomes to be in numerical order

Instead use samtools or biobambam2

The latter is recommended because uses less memory

```
module load biobambam2/2.0.146
```

Use bammarkduplicates

## 7: Index BAM files

Use samtools

## 8: SNP calling
