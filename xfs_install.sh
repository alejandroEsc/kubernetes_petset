#!/bin/bash

zone=$1
ig_nm=$2
cluster_nm=$1"/"$2
dt=`date +"%Y%m%d%H"`
FILE1=xfs_update_result_$dt.log

if [ -f $FILE1 ];
then
   mv $FILE1 $FILE1.bak
fi

set -f; IFS=$'\n'
gcmd=(`gcloud compute instance-groups list-instances $cluster_nm | awk -v var=$zone 'NR > 1 {print "gcloud compute ssh "var"/"$1 " '\''bash -s'\'' < ./xfs.sh"}'`)

for each in "${gcmd[@]}"
do
  eval "$each" >> ./xfs_update_result_$dt.log
done
