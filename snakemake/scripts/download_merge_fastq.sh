#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

if [[ $# -ne 3 ]] ; then
  echo "Incorrect number of arguments"
  exit 1
fi

output_fastq1=$1
output_fastq2=$2
units=$3

# Iterate over each sequencing run (i.e. unit)
count=0
for unit in $units; do
  ((count+=1))
  urls=`echo "$unit" | awk -F":" '{ print $1 }'`
  md5s=`echo "$unit" | awk -F":" '{ print $2 }'`
  url1=`echo "$urls" | awk -F";" '{ print $1 }'`
  url2=`echo "$urls" | awk -F";" '{ print $2 }'`
  md51=`echo "$md5s" | awk -F";" '{ print $1 }'`
  md52=`echo "$md5s" | awk -F";" '{ print $2 }'`

  # Get first FASTQ file and check checksum
  wget -q --timeout 60 --tries 10 -O "${output_fastq1}_tmp_$count.gz" "$url1"
  md5=`md5sum "${output_fastq1}_tmp_$count.gz" | awk '{ print $1 }'`
  if [ "$md51" != "$md5" ]; then
    echo "Checksum wrong for '$url1': '$md5' not '$md51'"
    exit 1
  fi
  gunzip "${output_fastq1}_tmp_$count.gz"

  # Get second FASTQ file and check checksum
  wget -q --timeout 60 --tries 10 -O "${output_fastq2}_tmp_$count.gz" "$url2"
  md5=`md5sum "${output_fastq2}_tmp_$count.gz" | awk '{ print $1 }'`
  if [ "$md52" != "$md5" ]; then
    echo "Checksum wrong for '$url2': '$md5' not '$md52'"
    exit 1
  fi
  gunzip "${output_fastq2}_tmp_$count.gz"
done

# Merge unzipped FASTQ files
cat `ls ${output_fastq1}_tmp_* | sort` > $output_fastq1
cat `ls ${output_fastq2}_tmp_* | sort` > $output_fastq2
rm ${output_fastq1}_tmp_* ${output_fastq2}_tmp_*
