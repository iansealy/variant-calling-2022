# Samples

Download all samples from ENA:

```
wget -O ena-runs.tsv 'https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB1830&result=read_run&fields=secondary_sample_accession,sample_alias,fastq_ftp,fastq_md5'
```

Remove header, unnecessary columns and tidy sample names:

```
cut -f3- ena-runs.tsv | sed -e 's/-sc-[^\t]*\t/\t/' | grep -v ^secondary_sample_accession | sort > ena-runs.tsv.tmp
mv ena-runs.tsv.tmp ena-runs.tsv
```

Check each sample only has two FASTQ files (each line should have two semi-colons):

```
sed -e 's/[^;]*//g' ena-runs.tsv | uniq -c
```

```
   5489 ;;
```

Extract all samples from list of Sanger samples and tidy up various names:

```
grep ^653 ~/zebrafish-samples-run-lane-tag.txt | cut -f2,3,5,6 | sed -e 's/\\n//g' | awk '{ print $2, $1, $3, $4 }' \
| sed -e 's/ NULL//g' | sed -E 's/ (.*) \1 \1/ \1/' | sed -E 's/ (.*)a \1a \1$/ \1/' | sed -e 's/ .* / /' | sed -e 's/a$//' | sed -e 's/\//_/' \
| sort -u > sanger-samples.tsv
```

`~/zebrafish-samples-run-lane-tag.txt` is a list of all the sequencing we did at Sanger, including various sample names

653 is the ID of the project for sequencing zebrafish exomes

Join ENA data and Sanger data and use Sanger names:

```
join -j1 sanger-samples.tsv ena-runs.tsv | awk '{ print $1 "\t" $2 "\t" $4 "\t" $5 }' > samples.tsv
```

Remove samples that aren't wild type or ZMP:

```
grep -vE '(sib|mut|Da_|SIB|MUT|wt|Nod2|Alb|C6[12])' samples.tsv > samples.tsv.tmp
mv samples.tsv.tmp samples.tsv
```

Final list is `samples.tsv`

```
wc -l samples.tsv 
5378 samples.tsv
```

Contains 5378 lines, corresponding to 5378 sequencing runs

```
cut -f2 samples.tsv | sort -u | wc -l
3849
```

But there are only 3849 unique names, which means that some samples appear on more than one sequencing run

This is because sometimes the same sequencing library was sequenced multiple times

```
cut -f1 samples.tsv | sort -u | wc -l
3870
```

There are 3870 unique accessions, which is higher than the number of sample names, because sometimes a sample was sequenced more than once, including making a new library, so it got a new accession

```
grep SL3_03_C7 samples.tsv
ERS036126       SL3_03_C7       ftp.sra.ebi.ac.uk/vol1/fastq/ERR059/ERR059450/ERR059450_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR059/ERR059450/ERR059450_2.fastq.gz   b28a01bdcc11a334587a5b50dc0f54c8;65cfc0c922a4133102b2bf0328212911
ERS036126       SL3_03_C7       ftp.sra.ebi.ac.uk/vol1/fastq/ERR062/ERR062817/ERR062817_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR062/ERR062817/ERR062817_2.fastq.gz   2d0ccbaf54ee3b6584aa81c444c58124;3ce3a33cc4302c99861db726d2db735a
```

When the same sample has been sequenced more than once, there's be multiple FASTQ pairs and all must be aligned before variants are called

```
grep mrf0127 samples.tsv 
ERS014624       mrf0127 ftp.sra.ebi.ac.uk/vol1/fastq/ERR031/ERR031104/ERR031104_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR031/ERR031104/ERR031104_2.fastq.gz   accb678173fe56b7e876669b7dc599f4;ed572aa767145143c223ac01dbc0594e
ERS018147       mrf0127 ftp.sra.ebi.ac.uk/vol1/fastq/ERR034/ERR034824/ERR034824_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR034/ERR034824/ERR034824_2.fastq.gz   6c4791ce065c9714dda43f1533711dbb;6d6c44d05888bdd53d2d42d52aa889fc
ERS018147       mrf0127 ftp.sra.ebi.ac.uk/vol1/fastq/ERR034/ERR034826/ERR034826_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR034/ERR034826/ERR034826_2.fastq.gz   e0432a1e1f0856b63fc4682c7b8bc645;1e723b642ce90ab8ff672cc1b7d662e8
```

This applies even if there's more than one accession

Which means that the unique ID that should be used for each sample should be the name, rather than the accession

Add strain and library (if relevant) to samples:

```
awk '{ if ($2 ~ /MR|mrf|sa0/) { print $0 "\tTL\tSL2" }
else if ($2 ~ /SL3/) { print $0 "\tSAT\tSL3" }
else if ($2 ~ /2011|SL4/) { print $0 "\tTL\tSL4" }
else if ($2 ~ /SL6/) { print $0 "\tTL\t$SL6" }
else if ($2 ~ /SL7/) { print $0 "\tTL\tSL7" }
else if ($2 ~ /SAT/) { print $0 "\tSAT\t-" }
else if ($2 ~ /WIK/) { print $0 "\tWIK\t-" }
else if ($2 ~ /AB/) { print $0 "\tAB\t-" }
else if ($2 ~ /Tu/) { print $0 "\tTU\t-" }
else if ($2 ~ /T_LF/) { print $0 "\tTL\t-" }
else if ($2 ~ /H_LF/) { print $0 "\tHLF\t-" }
else if ($2 ~ /Lon/) { print $0 "\tLON\t-" }
else { print $0 } }' samples.tsv \
> samples-all-metadata.tsv
```

If library is "-" then sample is wild type and not from ZMP and will not contain any induced mutations

Make files of samples and sequencing units:

```
cut -f 2-4 samples-all-metadata.tsv | sort > units.tsv
cut -f 2,5,6 samples-all-metadata.tsv | sort -u > samples.tsv
```
