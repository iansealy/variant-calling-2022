#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
  echo "Incorrect number of arguments"
  exit 1
fi

job=$1

qstat -j $job &> /dev/null
status=$?
if [ $status -eq 0 ]; then
  echo "running"
  exit 0
fi

status=`grep -F :$job:sge /opt/sge/default/common/accounting | cut -d\: -f13`
if [ $status -eq 0 ]; then
  echo "success"
else
  echo "failed"
fi
